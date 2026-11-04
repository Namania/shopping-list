import 'dart:convert';

import 'package:shopping_list/features/backup/data_dump.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';

/// The file format of backups and shared files: a JSON object tagged with
/// the app and a version, holding either a whole [DataDump] (a backup) or
/// the items of one kind (a share).
abstract final class TransferFile {
  static const app = 'shopping-list';
  static const version = 2;

  static String backup(DataDump dump, DateTime date) =>
      jsonEncode({'app': app, 'format': version, 'createdAt': date.toIso8601String(), ...dump.toJson()});

  static String share(SharePayload payload) =>
      jsonEncode({'app': app, 'format': version, 'kind': payload.kind.name, 'items': payload.items});
}

/// What an import brings, whatever it came from (QR code, link, file, old
/// backup), ready to preview: the lists, cards and categories it holds and,
/// for a backup, everything needed to replace the current data.
class ImportBundle {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> cards;
  final List<Map<String, dynamic>> lists;

  /// The exact data of a backup made by this version, prices included.
  final DataDump? dump;

  /// The settings of a backup.
  final AppSettings? settings;

  /// Whether this is a whole backup, which can replace the current data.
  final bool isBackup;

  final DateTime? createdAt;

  const ImportBundle({
    this.categories = const [],
    this.cards = const [],
    this.lists = const [],
    this.dump,
    this.settings,
    this.isBackup = false,
    this.createdAt,
  });

  bool get isEmpty => categories.isEmpty && cards.isEmpty && lists.isEmpty;

  factory ImportBundle.fromPayload(SharePayload payload) => _ofKind(payload.kind, payload.items);

  static ImportBundle _ofKind(ShareKind kind, List<Map<String, dynamic>> items) => switch (kind) {
    ShareKind.lists => ImportBundle(lists: items),
    ShareKind.cards => ImportBundle(cards: items),
    ShareKind.categories => ImportBundle(categories: items),
  };

  /// Reads the decoded content of a file. Throws a [FormatException] when
  /// it is not something the app wrote.
  factory ImportBundle.fromJson(Object? json) {
    try {
      return _parse(json);
    } on TypeError {
      throw const FormatException('Not a Shopping List file');
    }
  }

  static ImportBundle _parse(Object? json) {
    List<Map<String, dynamic>> items(Object? value) =>
        ((value as List<dynamic>?) ?? const []).cast<Map<String, dynamic>>();

    switch (json) {
      // Backup of this version.
      case {'tables': Map<String, dynamic> _}:
        final map = json as Map<String, dynamic>;
        final dump = DataDump.fromJson(map);
        final maps = dump.toShareMaps();
        return ImportBundle(
          categories: maps.categories,
          cards: maps.cards,
          lists: maps.lists,
          dump: dump,
          settings: dump.settings,
          isBackup: true,
          createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
        );
      // Shared file of this version.
      case {'kind': String kind, 'items': List<dynamic> list}:
        final shareKind = ShareKind.values.where((k) => k.name == kind).firstOrNull;
        if (shareKind == null) throw const FormatException('Unknown kind');
        return _ofKind(shareKind, items(list));
      // Backup of versions <= 1.3.x, and of the first SQLite versions.
      case Map<String, dynamic> map when map.containsKey('articles') || map.containsKey('cubits'):
        final settings = map['settings'] as Map<String, dynamic>?;
        final legacy = map['cubits'] as Map<String, dynamic>?;
        return ImportBundle(
          categories: items(map['categories']),
          cards: items(map['cards']),
          lists: items(map['articles']),
          settings: settings != null
              ? AppSettings.fromMap(settings)
              : legacy != null
              ? AppSettings.fromLegacyMap(legacy)
              : null,
          isBackup: true,
        );
      // Shared file of older versions: a bare list, its kind told by its items.
      case List<dynamic> list:
        final all = items(list);
        final first = all.firstOrNull;
        if (first == null) return const ImportBundle();
        final kind = first.containsKey('articles')
            ? ShareKind.lists
            : first.containsKey('code')
            ? ShareKind.cards
            : ShareKind.categories;
        return _ofKind(kind, all);
      default:
        throw const FormatException('Not a Shopping List file');
    }
  }

  /// Reads a `shopping-list://launch?data=…` link, `null` when it is not one.
  static ImportBundle? fromLink(String text) {
    final match = RegExp('${SharePayload.scheme}://${SharePayload.host}\\?(d|data)=[^\\s]+').firstMatch(text);
    final uri = match == null ? null : Uri.tryParse(match[0]!);
    if (uri == null) return null;
    final payload = SharePayload.fromUri(uri);
    return payload == null ? null : ImportBundle.fromPayload(payload);
  }

  /// Keeps only the chosen items, to be added to the current data.
  ImportBundle only({required Set<int> lists, required Set<int> cards, required Set<int> categories}) =>
      ImportBundle(
        lists: [
          for (final (i, l) in this.lists.indexed)
            if (lists.contains(i)) l,
        ],
        cards: [
          for (final (i, c) in this.cards.indexed)
            if (cards.contains(i)) c,
        ],
        categories: [
          for (final (i, c) in this.categories.indexed)
            if (categories.contains(i)) c,
        ],
      );
}
