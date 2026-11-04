import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';
import 'package:shopping_list/features/backup/data_dump.dart';
import 'package:shopping_list/features/sharing/import_bundle.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:uuid/uuid.dart';

/// What a backup file carries besides the collections.
typedef BackupSettings = ({AppSettings? settings});

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

  /// Adds what [bundle] holds to the current data.
  Future<void> add(ImportBundle bundle) async {
    await db.transaction((txn) => _addIn(txn, bundle));
    changes.notify();
  }

  /// Replaces the current data with the backup in [bundle] and returns its
  /// settings, already saved. A backup of this version is restored exactly,
  /// amounts included; an older one is rebuilt from its lists and cards.
  Future<AppSettings?> replaceWith(ImportBundle bundle) async {
    await db.transaction((txn) async {
      if (bundle.dump case final dump?) {
        await dump.restoreIn(txn);
        return;
      }
      for (final table in DataDump.tables.reversed) {
        await txn.delete(table);
      }
      await _addIn(txn, bundle);
      if (bundle.settings != null) await SettingsRepository.saveIn(txn, bundle.settings!);
    });
    changes.notify();
    return bundle.settings;
  }

  // Categories and cards first, so articles and lists can be linked to them.
  Future<void> _addIn(Transaction txn, ImportBundle bundle) async {
    for (final map in bundle.categories) {
      await _categories.importOneIn(txn, map);
    }
    for (final map in bundle.cards) {
      await _cards.importOneIn(txn, map);
    }
    for (final map in bundle.lists) {
      await _lists.importOneIn(txn, map);
    }
  }

  /// Restores a backup file (any version) and returns the settings it holds,
  /// saved. With [replace], the current data is removed first.
  Future<BackupSettings> importBackup(Map<String, dynamic> data, {bool replace = false}) async {
    final bundle = ImportBundle.fromJson(data);
    if (replace) return (settings: await replaceWith(bundle));
    await db.transaction((txn) async {
      await _addIn(txn, bundle);
      if (bundle.settings != null) await SettingsRepository.saveIn(txn, bundle.settings!);
    });
    changes.notify();
    return (settings: bundle.settings);
  }
}
