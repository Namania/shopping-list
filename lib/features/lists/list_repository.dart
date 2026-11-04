import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/database/app_database.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/article.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';
import 'package:uuid/uuid.dart';

/// What [ListRepository.remove] took away, so it can be put back. The prices
/// of the list are not kept.
class DeletedList {
  final ShoppingList list;
  final int position;

  const DeletedList(this.list, {required this.position});
}

/// What [ListRepository.removeArticle] took away, so it can be put back. Its
/// price, if any, is not kept.
class DeletedArticle {
  final Article article;
  final int position;

  const DeletedArticle(this.article, {required this.position});
}

class ListRepository {
  final Database db;
  final Uuid _uuid;

  ListRepository(this.db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  static const table = 'lists';
  static const articles = 'articles';

  static const _articleSelect = '''
      SELECT a.id, a.list_id, a.label, a.done, a.position,
             c.id AS category_id, c.label AS category_label, c.color AS category_color
      FROM articles a LEFT JOIN categories c ON c.id = a.category_id''';

  /// Articles in user-defined order, of one list or of all of them.
  static Future<List<Article>> _articlesIn(DatabaseExecutor txn, {String? listId}) async {
    final rows = await txn.rawQuery(
      '$_articleSelect${listId == null ? '' : ' WHERE a.list_id = ?'} ORDER BY a.position',
      listId == null ? const [] : [listId],
    );
    return rows.map(_articleFromRow).toList();
  }

  /// Every list with its articles, both in user-defined order.
  Future<List<ShoppingList>> all() async {
    final listRows = await db.query(table, orderBy: 'position');
    final allArticles = await _articlesIn(db);

    final byList = <String, List<Article>>{};
    for (final article in allArticles) {
      byList.putIfAbsent(article.listId, () => []).add(article);
    }
    return listRows
        .map(
          (row) => ShoppingList(
            id: row['id'] as String,
            label: row['label'] as String,
            cardId: row['card_id'] as String?,
            articles: byList[row['id']] ?? const [],
          ),
        )
        .toList();
  }

  // ---- lists ----

  /// Inserts a list; returns `false` when one with the same label exists.
  Future<bool> add(String label) async {
    final duplicate = await db.query(table, where: 'label = ?', whereArgs: [label]);
    if (duplicate.isNotEmpty) return false;
    await _insertList(db, ShoppingList(id: _uuid.v4(), label: label));
    return true;
  }

  Future<void> update(ShoppingList list) =>
      db.update(table, {'label': list.label, 'card_id': list.cardId}, where: 'id = ?', whereArgs: [list.id]);

  /// Articles and prices of the list go with it (FK ON DELETE CASCADE).
  /// Returns what is needed to [restore] the list and its articles.
  Future<DeletedList?> remove(String id) => db.transaction((txn) async {
    final rows = await txn.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final list = ShoppingList(
      id: id,
      label: row['label'] as String,
      cardId: row['card_id'] as String?,
      articles: await _articlesIn(txn, listId: id),
    );
    await txn.delete(table, where: 'id = ?', whereArgs: [id]);
    return DeletedList(list, position: row['position'] as int);
  });

  Future<void> restore(DeletedList deleted) => db.transaction((txn) async {
    await txn.makeRoomAt(table, deleted.position);
    await _insertList(txn, deleted.list, position: deleted.position);
    for (final article in deleted.list.articles) {
      await _insertArticle(txn, article);
    }
  });

  Future<void> reorder(int oldIndex, int newIndex) => db.reorder(table, oldIndex, newIndex);

  /// Puts the lists in the order of [ids]; lists not named keep their place
  /// after them.
  Future<void> setOrder(List<String> ids) => db.transaction((txn) async {
    final rows = await txn.query(table, columns: ['id'], orderBy: 'position');
    final rest = rows.map((r) => r['id'] as String).where((id) => !ids.contains(id));
    final batch = txn.batch();
    var position = 0;
    for (final id in [...ids, ...rest]) {
      batch.update(table, {'position': position++}, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  });

  /// Copies a list and its articles, all unchecked, under [label], at the
  /// end. Returns the new list's id, `null` when [sourceId] is unknown.
  Future<String?> duplicate(String sourceId, String label) => db.transaction((txn) async {
    final rows = await txn.query(table, where: 'id = ?', whereArgs: [sourceId]);
    if (rows.isEmpty) return null;
    final id = _uuid.v4();
    await _insertList(txn, ShoppingList(id: id, label: label, cardId: rows.first['card_id'] as String?));
    for (final article in await _articlesIn(txn, listId: sourceId)) {
      await _insertArticle(
        txn,
        Article(id: _uuid.v4(), listId: id, label: article.label, category: article.category),
      );
    }
    return id;
  });

  /// Unchecks every article of a list so it can be shopped again, and drops
  /// the prices entered for them.
  Future<void> restart(String listId) => db.transaction((txn) async {
    await txn.update(articles, {'done': 0}, where: 'list_id = ?', whereArgs: [listId]);
    await txn.delete('prices', where: 'list_id = ? AND article_id IS NOT NULL', whereArgs: [listId]);
  });

  // ---- articles ----

  /// Inserts an article; returns `false` when the list already has one with
  /// the same label.
  Future<bool> addArticle({required String listId, required String label, Category? category}) async {
    final duplicate = await db.query(
      articles,
      where: 'list_id = ? AND label = ?',
      whereArgs: [listId, label],
    );
    if (duplicate.isNotEmpty) return false;
    await _insertArticle(db, Article(id: _uuid.v4(), listId: listId, label: label, category: category));
    return true;
  }

  Future<void> updateArticle(Article article) => db.update(
    articles,
    {'label': article.label, 'category_id': article.category?.id, 'done': article.done ? 1 : 0},
    where: 'id = ?',
    whereArgs: [article.id],
  );

  Future<void> toggleDone(String articleId) =>
      db.rawUpdate('UPDATE articles SET done = NOT done WHERE id = ?', [articleId]);

  /// Prices of a removed article go with it (FK ON DELETE CASCADE). Returns
  /// what is needed to [restoreArticle].
  Future<DeletedArticle?> removeArticle(String id) => db.transaction((txn) async {
    final rows = await txn.rawQuery('$_articleSelect WHERE a.id = ?', [id]);
    if (rows.isEmpty) return null;
    await txn.delete(articles, where: 'id = ?', whereArgs: [id]);
    return DeletedArticle(_articleFromRow(rows.first), position: rows.first['position'] as int);
  });

  Future<void> restoreArticle(DeletedArticle deleted) => db.transaction((txn) async {
    await txn.makeRoomAt(
      articles,
      deleted.position,
      where: 'list_id = ?',
      whereArgs: [deleted.article.listId],
    );
    await _insertArticle(txn, deleted.article, position: deleted.position);
  });

  /// Removes every article of a list, or only the checked ones.
  Future<void> clear(String listId, {bool onlyDone = false}) =>
      db.delete(articles, where: onlyDone ? 'list_id = ? AND done = 1' : 'list_id = ?', whereArgs: [listId]);

  // ---- import (share / backup format) ----

  /// Adds the lists of a share / backup payload.
  Future<void> importAll(List<Map<String, dynamic>> maps, {bool keepIds = false}) =>
      db.transaction((txn) async {
        for (final map in maps) {
          await importOneIn(txn, map, keepIds: keepIds);
        }
      });

  /// Adds one list with its articles.
  Future<void> importOneIn(DatabaseExecutor txn, Map<String, dynamic> map, {bool keepIds = false}) async {
    final listId = await importListIn(txn, map, keepIds: keepIds);
    final categories = await CategoryRepository.allIn(txn);
    for (final article in articlesOf(map)) {
      await importArticleIn(txn, listId, article, categories);
    }
  }

  /// The articles of a list payload.
  static List<Map<String, dynamic>> articlesOf(Map<String, dynamic> map) =>
      (map['articles'] as List<dynamic>).cast<Map<String, dynamic>>();

  /// Adds the list itself (no articles) and returns its id. The list gets a
  /// fresh id unless [keepIds] is set; a link to an unknown card is dropped.
  Future<String> importListIn(DatabaseExecutor txn, Map<String, dynamic> map, {bool keepIds = false}) async {
    final givenId = map['id'] as String?;
    final listId = keepIds && givenId != null && givenId.isNotEmpty ? givenId : _uuid.v4();
    final card = map['card'] as String?;
    await _insertList(
      txn,
      ShoppingList(
        id: listId,
        label: map['label'] as String,
        cardId: card == null || card.isEmpty ? null : card,
      ),
    );
    return listId;
  }

  /// Adds one article of a payload to [listId]. The article keeps its id
  /// when it is free, otherwise it gets a fresh one. Its category is matched
  /// by label and color among [categories]; unknown ones become uncategorized.
  Future<void> importArticleIn(
    DatabaseExecutor txn,
    String listId,
    Map<String, dynamic> map,
    List<Category> categories,
  ) {
    final wanted = Category.fromMap(map['category'] as Map<String, dynamic>, id: '');
    final articleId = map['id'] as String?;
    return _insertArticle(
      txn,
      Article(
        id: articleId == null || articleId.isEmpty ? _uuid.v4() : articleId,
        listId: listId,
        label: map['label'] as String,
        done: map['done'] as bool? ?? false,
        category: categories.where((c) => c.sameAs(wanted)).firstOrNull,
      ),
    );
  }

  // ---- helpers ----

  Future<void> _insertList(DatabaseExecutor txn, ShoppingList list, {int? position}) async {
    var cardId = list.cardId;
    if (cardId != null) {
      final known = await txn.query('cards', columns: ['id'], where: 'id = ?', whereArgs: [cardId]);
      if (known.isEmpty) cardId = null;
    }
    await txn.insert(table, {
      'id': list.id,
      'label': list.label,
      'card_id': cardId,
      'position': position ?? await txn.nextPosition(table),
    });
  }

  Future<void> _insertArticle(DatabaseExecutor txn, Article article, {int? position}) async {
    final taken = await txn.query(articles, columns: ['id'], where: 'id = ?', whereArgs: [article.id]);
    var categoryId = article.category?.id;
    if (categoryId != null) {
      final known = await txn.query('categories', columns: ['id'], where: 'id = ?', whereArgs: [categoryId]);
      if (known.isEmpty) categoryId = null;
    }
    await txn.insert(articles, {
      'id': taken.isEmpty ? article.id : _uuid.v4(),
      'list_id': article.listId,
      'label': article.label,
      'category_id': categoryId,
      'done': article.done ? 1 : 0,
      'position':
          position ?? await txn.nextPosition(articles, where: 'list_id = ?', whereArgs: [article.listId]),
    });
  }

  static Article _articleFromRow(Map<String, Object?> row) => Article(
    id: row['id'] as String,
    listId: row['list_id'] as String,
    label: row['label'] as String,
    done: row['done'] == 1,
    category: row['category_id'] == null
        ? null
        : Category(
            id: row['category_id'] as String,
            label: row['category_label'] as String,
            color: Color(row['category_color'] as int),
          ),
  );
}
