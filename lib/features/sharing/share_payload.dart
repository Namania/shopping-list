import 'dart:convert';
import 'dart:io';

import 'package:shopping_list/core/utils/colors.dart';
import 'package:shopping_list/core/utils/compressed_json.dart';

/// What a share payload contains. The wire names are those of the first
/// versions of the app so QR codes keep working across versions.
enum ShareKind {
  lists('importArticles', '/lists'),
  categories('importCategories', '/categories'),
  cards('importCards', '/cards');

  final String action;

  /// Page to show once the payload is imported.
  final String route;

  const ShareKind(this.action, this.route);

  static ShareKind? fromAction(String? action) => values.where((kind) => kind.action == action).firstOrNull;
}

/// A collection shared through a QR code / deep link:
/// `shopping-list://launch?d=<compact>`. Links of older versions
/// (`?data=<compressed json>`) are still read.
class SharePayload {
  static const scheme = 'shopping-list';
  static const host = 'launch';

  final ShareKind kind;
  final List<Map<String, dynamic>> items;

  const SharePayload(this.kind, this.items);

  String toDeepLink() => '$scheme://$host?d=${CompactShare.encode(kind, items)}';

  static bool isDeepLink(Uri uri) => uri.scheme == scheme && uri.host == host;

  /// Whether [uri] carries shared data, in any version.
  static bool hasData(Uri uri) =>
      uri.queryParameters.containsKey('d') || uri.queryParameters.containsKey('data');

  /// Reads a share link, `null` when it does not hold a valid payload.
  static SharePayload? fromUri(Uri uri) {
    try {
      if (uri.queryParameters['d'] case final compact? when compact.isNotEmpty) {
        return CompactShare.decode(compact);
      }
      return _decodeLegacy(uri.queryParameters['data']);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  static SharePayload? _decodeLegacy(String? data) {
    if (data == null || data.isEmpty) return null;
    final map = jsonDecode(decompressJson(data)) as Map<String, dynamic>;
    final kind = ShareKind.fromAction(map['action'] as String?);
    if (kind == null) return null;
    return SharePayload(kind, (map['json'] as List<dynamic>).cast<Map<String, dynamic>>());
  }
}

/// The share format sized for QR codes: JSON arrays instead of objects, no
/// ids (the receiver makes its own), each category written once and
/// referred to by position, colours without their opaque alpha, then raw
/// deflate at the highest level and URL-safe base64 without padding.
///
/// - lists: `["lists", [[category, rgb]…], [[label, [article…]]…]]` where an
///   article is its label, or `[label, category index, 1 if done]`;
/// - cards: `["cards", [[label, code, rgb, format]…]]`;
/// - categories: `["categories", [[label, rgb]…]]`.
abstract final class CompactShare {
  static final _deflate = ZLibCodec(raw: true, level: ZLibOption.maxLevel);

  static String encode(ShareKind kind, List<Map<String, dynamic>> items) {
    final json = jsonEncode(switch (kind) {
      ShareKind.lists => _lists(items),
      ShareKind.cards => [
        kind.name,
        [
          for (final c in items) [c['label'], c['code'], _rgb(c['color'] as int?), c['format'] ?? 'code128'],
        ],
      ],
      ShareKind.categories => [
        kind.name,
        [
          for (final c in items) [c['label'], _rgb(c['color'] as int?)],
        ],
      ],
    });
    return base64Url.encode(_deflate.encode(utf8.encode(json))).replaceAll('=', '');
  }

  static List<Object> _lists(List<Map<String, dynamic>> lists) {
    final categories = <String, int>{};
    final table = <List<Object?>>[];
    int indexOf(Map<String, dynamic> category) => categories.putIfAbsent(jsonEncode(category), () {
      table.add([category['label'], _rgb(category['color'] as int?)]);
      return table.length - 1;
    });

    return [
      ShareKind.lists.name,
      table,
      [
        for (final list in lists)
          [
            list['label'],
            [
              for (final a in (list['articles'] as List<dynamic>).cast<Map<String, dynamic>>())
                switch ((a['category'] as Map<String, dynamic>?, a['done'] == true)) {
                  (null, false) => a['label'],
                  (null, true) => [a['label'], -1, 1],
                  (final category?, final done) => [a['label'], indexOf(category), if (done) 1],
                },
            ],
          ],
      ],
    ];
  }

  static SharePayload decode(String compact) {
    final padded = compact.padRight((compact.length + 3) ~/ 4 * 4, '=');
    final json = jsonDecode(utf8.decode(_deflate.decode(base64Url.decode(padded)))) as List<dynamic>;
    final kind = ShareKind.values.byName(json[0] as String);
    final items = switch (kind) {
      ShareKind.lists => _readLists(json[1] as List<dynamic>, json[2] as List<dynamic>),
      ShareKind.cards => [
        for (final c in (json[1] as List<dynamic>).cast<List<dynamic>>())
          <String, dynamic>{'label': c[0], 'code': c[1], 'color': _argb(c[2] as int), 'format': c[3]},
      ],
      ShareKind.categories => [
        for (final c in (json[1] as List<dynamic>).cast<List<dynamic>>())
          <String, dynamic>{'label': c[0], 'color': _argb(c[1] as int)},
      ],
    };
    return SharePayload(kind, items);
  }

  static List<Map<String, dynamic>> _readLists(List<dynamic> table, List<dynamic> lists) {
    final categories = [
      for (final c in table.cast<List<dynamic>>())
        <String, dynamic>{'label': c[0], 'color': _argb(c[1] as int)},
    ];
    const none = <String, dynamic>{'label': '', 'color': 0};
    return [
      for (final list in lists.cast<List<dynamic>>())
        <String, dynamic>{
          'label': list[0],
          'articles': [
            for (final a in list[1] as List<dynamic>)
              switch (a) {
                String label => <String, dynamic>{'label': label, 'category': none, 'done': false},
                List<dynamic> a => <String, dynamic>{
                  'label': a[0],
                  'category': (a[1] as int) < 0 ? none : categories[a[1] as int],
                  'done': a.length > 2 && a[2] == 1,
                },
                _ => throw const FormatException('Bad article'),
              },
          ],
        },
    ];
  }

  /// Colours are made visible first (see [opaqueColor]), then lose their
  /// alpha byte: fewer digits.
  static int _rgb(int? argb) => opaqueColor(argb).toARGB32() & 0xFFFFFF;

  static int _argb(int value) => value <= 0xFFFFFF ? value | 0xFF000000 : value;
}
