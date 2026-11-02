import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/features/prices/price.dart';
import 'package:uuid/uuid.dart';

class PriceRepository {
  final Database db;
  final Uuid _uuid;

  PriceRepository(this.db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  static const table = 'prices';

  Future<List<Price>> all() async {
    final rows = await db.query(table, orderBy: 'rowid');
    return rows.map(_fromRow).toList();
  }

  /// Records the price of an article (one price per article).
  Future<void> setForArticle({required String listId, required String articleId, required int cents}) =>
      db.insert(table, {
        'id': _uuid.v4(),
        'list_id': listId,
        'article_id': articleId,
        'cents': cents,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

  /// Records an amount that is not tied to an article.
  Future<void> addManual({required int cents, String? listId}) =>
      db.insert(table, {'id': _uuid.v4(), 'list_id': listId, 'cents': cents});

  Future<void> update(Price price) =>
      db.update(table, {'cents': price.cents}, where: 'id = ?', whereArgs: [price.id]);

  /// Removes a price and returns it, so it can be put back with [restore].
  Future<Price?> remove(String id) async {
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
    return _fromRow(rows.first);
  }

  Future<void> restore(Price price) => db.insert(table, {
    'id': price.id,
    'list_id': price.listId,
    'article_id': price.articleId,
    'cents': price.cents,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<void> removeForArticle(String articleId) =>
      db.delete(table, where: 'article_id = ?', whereArgs: [articleId]);

  /// Clears prices. [linked] restricts the deletion to prices tied to an
  /// article (`true`) or entered by hand (`false`).
  Future<void> clear({String? listId, bool? linked}) {
    final where = <String>[];
    final args = <Object?>[];
    if (listId != null) {
      where.add('list_id = ?');
      args.add(listId);
    }
    if (linked != null) where.add(linked ? 'article_id IS NOT NULL' : 'article_id IS NULL');
    return db.delete(table, where: where.isEmpty ? null : where.join(' AND '), whereArgs: args);
  }

  static Price _fromRow(Map<String, Object?> row) => Price(
    id: row['id'] as String,
    listId: row['list_id'] as String?,
    articleId: row['article_id'] as String?,
    cents: row['cents'] as int,
  );
}
