import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late CategoryRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = CategoryRepository(db);
  });

  tearDown(() => db.close());

  test('add keeps insertion order and skips duplicates', () async {
    await repo.add(label: 'Fruits', color: const Color(0xFF4CAF50));
    await repo.add(label: 'Dairy', color: const Color(0xFF2196F3));
    await repo.add(label: 'Fruits', color: const Color(0xFF4CAF50));

    final all = await repo.all();
    expect(all.map((c) => c.label), ['Fruits', 'Dairy']);
  });

  test('update changes label and color', () async {
    final fruits = await repo.add(label: 'Fruits', color: const Color(0xFF4CAF50));
    await repo.update(fruits.copyWith(label: 'Fruits & veg', color: const Color(0xFFF44336)));

    final all = await repo.all();
    expect(all.single.label, 'Fruits & veg');
    expect(all.single.color, const Color(0xFFF44336));
  });

  test('reorder moves an item and keeps positions dense', () async {
    for (final label in ['A', 'B', 'C', 'D']) {
      await repo.add(label: label, color: const Color(0xFF000000));
    }
    await repo.reorder(0, 2);
    expect((await repo.all()).map((c) => c.label), ['B', 'C', 'A', 'D']);

    await repo.reorder(3, 0);
    expect((await repo.all()).map((c) => c.label), ['D', 'B', 'C', 'A']);
  });

  test('removing a category makes its articles uncategorized', () async {
    final fruits = await repo.add(label: 'Fruits', color: const Color(0xFF4CAF50));
    final lists = ListRepository(db);
    await lists.add('Groceries');
    final list = (await lists.all()).single;
    await lists.addArticle(listId: list.id, label: 'Apples', category: fruits);

    await repo.remove(fruits.id);

    final article = (await lists.all()).single.articles.single;
    expect(article.label, 'Apples');
    expect(article.category, isNull);
  });

  test('importAll adds only the missing categories', () async {
    await repo.add(label: 'Fruits', color: const Color(0xFF4CAF50));
    await repo.importAll([
      {'label': 'Fruits', 'color': const Color(0xFF4CAF50).toARGB32()},
      {'label': 'Bakery', 'color': const Color(0xFFFF9800).toARGB32()},
    ]);

    expect((await repo.all()).map((c) => c.label), ['Fruits', 'Bakery']);
  });
}
