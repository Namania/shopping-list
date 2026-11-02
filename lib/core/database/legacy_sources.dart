import 'dart:developer';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/database/legacy_migration.dart';

const _legacyPrefKeys = ['articles', 'cards', 'categories', 'calculator', 'calculator_without_article'];

/// Runs [LegacyMigration] on the first launch after the update to SQLite,
/// reading the stores of versions <= 1.3.x.
///
/// The legacy stores are cleared once every entry has been imported. When
/// some entries could not be read they are kept as a safety copy (the
/// migration is still done; the copy is there for support). If the migration
/// itself fails, nothing is written, the stores are left intact for the next
/// launch and the app starts anyway.
Future<void> migrateLegacyData(Database db) async {
  if (await LegacyMigration.isDone(db)) return;

  final prefs = await SharedPreferences.getInstance();
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  // hydrated_bloc hands back untyped maps.
  Map<String, dynamic>? setting(String cubit) => (storage.read(cubit) as Map?)?.cast<String, dynamic>();

  final data = LegacyData(
    lists: prefs.getString('articles'),
    cards: prefs.getString('cards'),
    categories: prefs.getString('categories'),
    prices: prefs.getString('calculator'),
    manualPrices: prefs.getString('calculator_without_article'),
    theme: setting('ThemeCubit'),
    startRoute: setting('SettingRouterCubit'),
    categoryPosition: setting('SettingDefaultCategoryPosition'),
    calculator: setting('SettingEnableCalculator'),
  );

  try {
    final report = await LegacyMigration.run(db, data);
    log('Legacy data migrated ($report)', name: 'migration');
    if (report.complete) {
      for (final key in _legacyPrefKeys) {
        await prefs.remove(key);
      }
      await storage.clear();
    } else {
      log('Some entries were skipped, legacy stores kept as a copy', name: 'migration');
    }
  } catch (error, stackTrace) {
    log(
      'Legacy migration failed, legacy stores kept',
      name: 'migration',
      error: error,
      stackTrace: stackTrace,
    );
  } finally {
    await storage.close();
  }
}
