import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/utils/colors.dart';
import 'package:shopping_list/core/database/app_database.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:uuid/uuid.dart';

/// What [CategoryRepository.remove] took away, so it can be put back.
class DeletedCategory {
  final Category category;
  final int position;
  final List<String> articleIds;

  const DeletedCategory(this.category, {required this.position, required this.articleIds});
}

class CategoryRepository {
  final Database db;
  final Uuid _uuid;

  CategoryRepository(this.db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  static const table = 'categories';

  Future<List<Category>> all() => allIn(db);

  static Future<List<Category>> allIn(DatabaseExecutor txn) async {
    final rows = await txn.query(table, orderBy: 'position');
    return rows.map(_fromRow).toList();
  }

  /// Inserts [label]/[color] unless an identical category already exists.
  /// Returns the category that now holds these values.
  Future<Category> add({required String label, required Color color}) =>
      addIn(db, label: label, color: color);

  Future<void> update(Category category) => db.update(
    table,
    {'label': category.label, 'color': category.color.toARGB32()},
    where: 'id = ?',
    whereArgs: [category.id],
  );

  /// Articles of a removed category become uncategorized (FK ON DELETE SET NULL).
  /// Returns what is needed to [restore] the category.
  Future<DeletedCategory?> remove(String id) => db.transaction((txn) async {
    final rows = await txn.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final articles = await txn.query('articles', columns: ['id'], where: 'category_id = ?', whereArgs: [id]);
    await txn.delete(table, where: 'id = ?', whereArgs: [id]);
    return DeletedCategory(
      _fromRow(rows.first),
      position: rows.first['position'] as int,
      articleIds: articles.map((r) => r['id'] as String).toList(),
    );
  });

  Future<void> restore(DeletedCategory deleted) => db.transaction((txn) async {
    await txn.makeRoomAt(table, deleted.position);
    await txn.insert(table, {
      'id': deleted.category.id,
      'label': deleted.category.label,
      'color': deleted.category.color.toARGB32(),
      'position': deleted.position,
    });
    for (final articleId in deleted.articleIds) {
      await txn.update(
        'articles',
        {'category_id': deleted.category.id},
        where: 'id = ?',
        whereArgs: [articleId],
      );
    }
  });

  Future<void> removeAll() => db.delete(table);

  Future<void> reorder(int oldIndex, int newIndex) => db.reorder(table, oldIndex, newIndex);

  /// Adds the categories of a share / backup payload that don't exist yet.
  Future<void> importAll(List<Map<String, dynamic>> maps) => db.transaction((txn) async {
    for (final map in maps) {
      await importOneIn(txn, map);
    }
  });

  /// Adds one category of a share / backup payload (`{label, color}`).
  Future<Category> importOneIn(DatabaseExecutor txn, Map<String, dynamic> map) =>
      addIn(txn, label: map['label'] as String, color: opaqueColor(map['color'] as int?));

  Future<Category> addIn(DatabaseExecutor txn, {required String label, required Color color}) async {
    final existing = await txn.query(
      table,
      where: 'label = ? AND color = ?',
      whereArgs: [label, color.toARGB32()],
    );
    if (existing.isNotEmpty) return _fromRow(existing.first);
    final category = Category(id: _uuid.v4(), label: label, color: color);
    await txn.insert(table, {
      'id': category.id,
      'label': label,
      'color': color.toARGB32(),
      'position': await txn.nextPosition(table),
    });
    return category;
  }

  static Category _fromRow(Map<String, Object?> row) => Category(
    id: row['id'] as String,
    label: row['label'] as String,
    color: opaqueColor(row['color'] as int?),
  );
}
