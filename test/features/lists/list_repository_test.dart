import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/prices/price_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late ListRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = ListRepository(db);
  });

  tearDown(() => db.close());

  test('lists and articles keep their insertion order', () async {
    await repo.add('Groceries');
    await repo.add('Party');
    await repo.add('Groceries');
    final [groceries, party] = await repo.all();
    expect(party.label, 'Party');

    await repo.addArticle(listId: groceries.id, label: 'Milk');
    await repo.addArticle(listId: groceries.id, label: 'Eggs');
    await repo.addArticle(listId: groceries.id, label: 'Milk');
    await repo.addArticle(listId: party.id, label: 'Chips');

    final all = await repo.all();
    expect(all.first.articles.map((a) => a.label), ['Milk', 'Eggs']);
    expect(all.last.articles.map((a) => a.label), ['Chips']);
  });

  test('articles carry their category', () async {
    final fruits = await CategoryRepository(db).add(label: 'Fruits', color: const Color(0xFF4CAF50));
    await repo.add('Groceries');
    final list = (await repo.all()).single;
    await repo.addArticle(listId: list.id, label: 'Apples', category: fruits);
    await repo.addArticle(listId: list.id, label: 'Bread');

    final [apples, bread] = (await repo.all()).single.articles;
    expect(apples.category, fruits);
    expect(bread.category, isNull);

    await repo.updateArticle(bread.copyWith(category: fruits, label: 'Baguette'));
    final updated = (await repo.all()).single.articles.last;
    expect(updated.label, 'Baguette');
    expect(updated.category, fruits);
  });

  test('toggleDone and clear', () async {
    await repo.add('Groceries');
    final list = (await repo.all()).single;
    await repo.addArticle(listId: list.id, label: 'Milk');
    await repo.addArticle(listId: list.id, label: 'Eggs');
    final milk = (await repo.all()).single.articles.first;

    await repo.toggleDone(milk.id);
    expect((await repo.all()).single.articles.first.done, isTrue);

    await repo.clear(list.id, onlyDone: true);
    expect((await repo.all()).single.articles.map((a) => a.label), ['Eggs']);

    await repo.clear(list.id);
    expect((await repo.all()).single.articles, isEmpty);
  });

  test('removing a list or an article removes their prices', () async {
    await repo.add('Groceries');
    final list = (await repo.all()).single;
    await repo.addArticle(listId: list.id, label: 'Milk');
    final milk = (await repo.all()).single.articles.single;
    final prices = PriceRepository(db);
    await prices.setForArticle(listId: list.id, articleId: milk.id, cents: 150);
    await prices.addManual(listId: list.id, cents: 200);

    await repo.removeArticle(milk.id);
    expect((await prices.all()).map((p) => p.cents), [200]);

    await repo.remove(list.id);
    expect(await prices.all(), isEmpty);
  });

  test('importAll resolves categories and gives lists fresh ids', () async {
    final fruits = await CategoryRepository(db).add(label: 'Fruits', color: const Color(0xFF4CAF50));
    final payload = [
      {
        'id': 'old-list',
        'label': 'Shared',
        'card': '',
        'articles': [
          {'id': 'a1', 'label': 'Apples', 'category': fruits.toMap(), 'done': true},
          {
            'id': 'a2',
            'label': 'Mystery',
            'category': {'label': 'Unknown', 'color': 0},
            'done': false,
          },
        ],
      },
    ];

    await repo.importAll(payload);
    final list = (await repo.all()).single;
    expect(list.id, isNot('old-list'));
    expect(list.cardId, isNull);
    expect(list.articles.first.category, fruits);
    expect(list.articles.first.done, isTrue);
    expect(list.articles.last.category, isNull);

    await repo.importAll(payload, keepIds: true);
    expect((await repo.all()).map((l) => l.id), contains('old-list'));
  });

  test('importAll drops a link to an unknown card and frees a taken article id', () async {
    await repo.add('Existing');
    final existing = (await repo.all()).single;
    await repo.addArticle(listId: existing.id, label: 'Milk');
    final milkId = (await repo.all()).single.articles.single.id;

    await repo.importAll([
      {
        'label': 'Imported',
        'card': 'ghost',
        'articles': [
          {
            'id': milkId,
            'label': 'Eggs',
            'category': {'label': 'x', 'color': 0},
            'done': false,
          },
        ],
      },
    ]);

    final imported = (await repo.all()).last;
    expect(imported.cardId, isNull);
    expect(imported.articles.single.label, 'Eggs');
    expect(imported.articles.single.id, isNot(milkId));
    expect((await repo.all()).first.articles.single.label, 'Milk');
  });

  test('restart unchecks every article and drops their prices', () async {
    await repo.add('Groceries');
    final list = (await repo.all()).single;
    await repo.addArticle(listId: list.id, label: 'Milk');
    await repo.addArticle(listId: list.id, label: 'Eggs');
    final [milk, eggs] = (await repo.all()).single.articles;
    await repo.toggleDone(milk.id);
    await repo.toggleDone(eggs.id);
    final prices = PriceRepository(db);
    await prices.setForArticle(listId: list.id, articleId: milk.id, cents: 150);
    await prices.addManual(listId: list.id, cents: 200);

    await repo.restart(list.id);

    expect((await repo.all()).single.articles.every((a) => !a.done), isTrue);
    expect((await prices.all()).map((p) => p.cents), [200], reason: 'hand-entered amounts stay');
  });

  test('duplicate copies the articles unchecked, with their category and card', () async {
    final fruits = await CategoryRepository(db).add(label: 'Fruits', color: const Color(0xFF4CAF50));
    await repo.add('Weekly');
    final source = (await repo.all()).single;
    await repo.addArticle(listId: source.id, label: 'Apples', category: fruits);
    await repo.toggleDone((await repo.all()).single.articles.single.id);

    final id = await repo.duplicate(source.id, 'Weekly (copy)');

    final copy = (await repo.all()).firstWhere((l) => l.id == id);
    expect(copy.label, 'Weekly (copy)');
    expect(copy.articles.single.label, 'Apples');
    expect(copy.articles.single.done, isFalse);
    expect(copy.articles.single.category, fruits);
    expect((await repo.all()).first.articles.single.done, isTrue, reason: 'source untouched');
  });

  test('setOrder puts the named lists first, the others after in their order', () async {
    for (final label in ['A', 'B', 'C', 'D']) {
      await repo.add(label);
    }
    final ids = {for (final l in await repo.all()) l.label: l.id};
    await repo.setOrder([ids['C']!, ids['A']!]);
    expect((await repo.all()).map((l) => l.label), ['C', 'A', 'B', 'D']);
  });
}
