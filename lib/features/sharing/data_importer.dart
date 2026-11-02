import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:uuid/uuid.dart';

/// What a backup file carries besides the collections.
typedef BackupSettings = ({AppSettings? settings, String? lang});

/// Writes shared payloads and backup files into the database, each in a
/// single transaction: a malformed item leaves nothing behind.
class DataImporter {
  final Database db;
  final DataChanges changes;
  final CategoryRepository _categories;
  final CardRepository _cards;
  final ListRepository _lists;

  DataImporter(this.db, this.changes, {Uuid uuid = const Uuid()})
    : _categories = CategoryRepository(db, uuid: uuid),
      _cards = CardRepository(db, uuid: uuid),
      _lists = ListRepository(db, uuid: uuid);

  /// Adds the items of a QR code / deep link / shared file.
  Future<void> importShared(ShareKind kind, List<Map<String, dynamic>> items) async {
    await db.transaction((txn) async {
      for (final item in items) {
        await switch (kind) {
          ShareKind.categories => _categories.importOneIn(txn, item),
          ShareKind.cards => _cards.importOneIn(txn, item),
          ShareKind.lists => _lists.importOneIn(txn, item),
        };
      }
    });
    changes.notify();
  }

  /// Restores a backup file and returns the settings it holds. The file
  /// format is the one of versions <= 1.3.x, whose settings were stored under
  /// `cubits`; newer files use `settings`.
  ///
  /// With [replace], every existing list, article, price, card and category
  /// is removed first, so the database ends up as the file describes it.
  Future<BackupSettings> importBackup(Map<String, dynamic> data, {bool replace = false}) async {
    List<Map<String, dynamic>> items(String key) =>
        ((data[key] as List<dynamic>?) ?? const []).cast<Map<String, dynamic>>();

    final settingsMap = data['settings'] as Map<String, dynamic>?;
    final legacyMap = data['cubits'] as Map<String, dynamic>?;
    final settings =
        settingsMap != null
            ? AppSettings.fromMap(settingsMap)
            : legacyMap != null
            ? AppSettings.fromLegacyMap(legacyMap)
            : null;

    await db.transaction((txn) async {
      if (replace) {
        for (final table in ['prices', 'articles', 'lists', 'cards', 'categories']) {
          await txn.delete(table);
        }
      }
      // Categories and cards first, so articles and lists can be linked to them.
      for (final map in items('categories')) {
        await _categories.importOneIn(txn, map);
      }
      for (final map in items('cards')) {
        await _cards.importOneIn(txn, map);
      }
      for (final map in items('articles')) {
        await _lists.importOneIn(txn, map);
      }
      if (settings != null) await SettingsRepository.saveIn(txn, settings);
    });
    changes.notify();
    return (settings: settings, lang: (settingsMap ?? legacyMap)?['lang'] as String?);
  }
}
