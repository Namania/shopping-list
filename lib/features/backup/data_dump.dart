import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';

/// Every row of the user's data, table by table, plus the settings: what a
/// backup file and a restore point hold. Restoring it gives back exactly the
/// same data, ids, order and amounts included.
class DataDump {
  /// The data tables, parents before children.
  static const tables = ['categories', 'cards', 'lists', 'articles', 'prices'];

  final Map<String, List<Map<String, Object?>>> rows;
  final AppSettings? settings;

  const DataDump(this.rows, {this.settings});

  static Future<DataDump> read(Database db) async => DataDump({
    for (final table in tables) table: await db.query(table, orderBy: 'rowid'),
  }, settings: await SettingsRepository(db).load());

  int count(String table) => rows[table]?.length ?? 0;

  bool get isEmpty => tables.every((t) => count(t) == 0);

  /// Replaces every row of the data tables with this dump's. Columns the
  /// database does not know (a file from a newer version) are left out.
  Future<void> restoreIn(Transaction txn) async {
    for (final table in tables.reversed) {
      await txn.delete(table);
    }
    for (final table in tables) {
      final known = {for (final c in await txn.rawQuery('PRAGMA table_info($table)')) c['name'] as String};
      for (final row in rows[table] ?? const <Map<String, Object?>>[]) {
        await txn.insert(table, {
          for (final MapEntry(:key, :value) in row.entries)
            if (known.contains(key)) key: value,
        });
      }
    }
    if (settings != null) await SettingsRepository.saveIn(txn, settings!);
  }

  Map<String, dynamic> toJson() => {'tables': rows, if (settings != null) 'settings': settings!.toMap()};

  factory DataDump.fromJson(Map<String, dynamic> json) {
    final tables = json['tables'] as Map<String, dynamic>;
    final settings = json['settings'] as Map<String, dynamic>?;
    return DataDump({
      for (final table in DataDump.tables)
        table: [
          for (final row in (tables[table] as List<dynamic>?) ?? const [])
            (row as Map).cast<String, Object?>(),
        ],
    }, settings: settings == null ? null : AppSettings.fromMap(settings));
  }

  /// The same data in the share format, to add it to existing data rather
  /// than replace it. Articles without a category get one no category
  /// matches, so they stay uncategorized.
  ({
    List<Map<String, dynamic>> categories,
    List<Map<String, dynamic>> cards,
    List<Map<String, dynamic>> lists,
  })
  toShareMaps() {
    final categories = {
      for (final c in rows['categories']!) c['id']: {'label': c['label'], 'color': c['color']},
    };
    const none = {'label': '', 'color': 0};
    return (
      categories: categories.values.toList(),
      cards: [
        for (final c in rows['cards']!)
          {'id': c['id'], 'label': c['label'], 'code': c['code'], 'color': c['color'], 'format': c['format']},
      ],
      lists: [
        for (final l in [
          ...rows['lists']!,
        ]..sort((a, b) => (a['position'] as int).compareTo(b['position'] as int)))
          {
            'id': l['id'],
            'label': l['label'],
            'card': l['card_id'] ?? '',
            'articles': [
              for (final a
                  in rows['articles']!.where((a) => a['list_id'] == l['id']).toList()
                    ..sort((a, b) => (a['position'] as int).compareTo(b['position'] as int)))
                {
                  'id': a['id'],
                  'label': a['label'],
                  'category': categories[a['category_id']] ?? none,
                  'done': a['done'] == 1,
                },
            ],
          },
      ],
    );
  }
}
