import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/utils/colors.dart';

/// Opens the app database and owns its schema.
///
/// Every repository works on the [Database] returned by [open]. Tests open an
/// in-memory database through `sqflite_common_ffi` with the same schema.
class AppDatabase {
  static const latestVersion = 3;

  static Future<Database> open({
    DatabaseFactory? factory,
    String? path,
    @visibleForTesting int version = latestVersion,
  }) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await dbFactory.getDatabasesPath(), 'shopping_list.db');
    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) => _createSchema(db, version),
        onUpgrade: _upgrade,
      ),
    );
  }

  static Future<void> _createSchema(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE settings (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE categories (
        id       TEXT PRIMARY KEY,
        label    TEXT NOT NULL,
        color    INTEGER NOT NULL,
        position INTEGER NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE cards (
        id       TEXT PRIMARY KEY,
        label    TEXT NOT NULL,
        code     TEXT NOT NULL,
        color    INTEGER NOT NULL,
        position INTEGER NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE lists (
        id       TEXT PRIMARY KEY,
        label    TEXT NOT NULL,
        card_id  TEXT REFERENCES cards(id) ON DELETE SET NULL,
        position INTEGER NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE articles (
        id          TEXT PRIMARY KEY,
        list_id     TEXT NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
        label       TEXT NOT NULL,
        category_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
        done        INTEGER NOT NULL DEFAULT 0,
        position    INTEGER NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE prices (
        id         TEXT PRIMARY KEY,
        list_id    TEXT REFERENCES lists(id) ON DELETE CASCADE,
        article_id TEXT UNIQUE REFERENCES articles(id) ON DELETE CASCADE,
        cents      INTEGER NOT NULL
      )''');
    await batch.commit(noResult: true);
    await _upgrade(db, 1, version);
  }

  /// Applies every schema change after [oldVersion], one version at a time.
  static Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      // v2: cards remember the format of their barcode.
      await db.execute("ALTER TABLE cards ADD COLUMN format TEXT NOT NULL DEFAULT 'code128'");
    }
    if (oldVersion < 3 && newVersion >= 3) {
      // v3: no invisible colours. Cards of older versions could have none
      // (stored transparent): they get the logo's violet; translucent
      // colours become opaque.
      for (final table in ['cards', 'categories']) {
        await db.execute(
          'UPDATE $table SET color = CASE WHEN (color >> 24) & 255 = 0 THEN ? ELSE color | ? END',
          [fallbackItemColor.toARGB32(), 0xFF000000],
        );
      }
    }
  }
}

/// Helpers shared by the repositories for tables that keep a user-defined
/// order in a `position` column.
extension PositionedTable on DatabaseExecutor {
  Future<int> nextPosition(String table, {String? where, List<Object?>? whereArgs}) async {
    final rows = await query(
      table,
      columns: ['COALESCE(MAX(position), -1) + 1 AS next'],
      where: where,
      whereArgs: whereArgs,
    );
    return rows.first['next'] as int;
  }

  /// Shifts the rows at or after [position] down by one, so a row can be put
  /// back where it was.
  Future<void> makeRoomAt(String table, int position, {String? where, List<Object?>? whereArgs}) => rawUpdate(
    'UPDATE $table SET position = position + 1 WHERE position >= ?${where == null ? '' : ' AND $where'}',
    [position, ...?whereArgs],
  );

  /// Moves the row at [oldIndex] to [newIndex] and rewrites the positions of
  /// the whole table (or of the subset selected by [where]) so they stay dense.
  Future<void> reorder(
    String table,
    int oldIndex,
    int newIndex, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = await query(table, columns: ['id'], where: where, whereArgs: whereArgs, orderBy: 'position');
    final ids = rows.map((r) => r['id'] as String).toList();
    if (oldIndex < 0 || oldIndex >= ids.length) return;
    ids.insert(newIndex.clamp(0, ids.length - 1), ids.removeAt(oldIndex));
    final batch = this.batch();
    for (var i = 0; i < ids.length; i++) {
      batch.update(table, {'position': i}, where: 'id = ?', whereArgs: [ids[i]]);
    }
    await batch.commit(noResult: true);
  }
}
