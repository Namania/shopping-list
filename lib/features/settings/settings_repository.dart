import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/features/settings/app_settings.dart';

/// Stores [AppSettings] as a single JSON value in the `settings` table.
class SettingsRepository {
  final Database db;

  SettingsRepository(this.db);

  static const table = 'settings';
  static const _key = 'app';

  Future<AppSettings> load() async {
    final rows = await db.query(table, where: 'key = ?', whereArgs: [_key]);
    if (rows.isEmpty) return const AppSettings();
    return AppSettings.fromMap(jsonDecode(rows.first['value'] as String) as Map<String, dynamic>);
  }

  Future<void> save(AppSettings settings) => saveIn(db, settings);

  static Future<void> saveIn(DatabaseExecutor txn, AppSettings settings) => txn.insert(table, {
    'key': _key,
    'value': jsonEncode(settings.toMap()),
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}
