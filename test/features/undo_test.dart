import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/prices/price_repository.dart';
import 'package:shopping_list/features/sharing/data_importer.dart';

import '../helpers/test_database.dart';

const blue = Color(0xFF2196F3);

void main() {
  late Database db;
  late CategoryRepository categories;
  late CardRepository cards;
  late ListRepository lists;
  late PriceRepository prices;

  setUp(() async {
    db = await openTestDatabase();
    categories = CategoryRepository(db);
    cards = CardRepository(db);
    lists = ListRepository(db);
    prices = PriceRepository(db);
  });

  tearDown(() => db.close());

  test('a deleted category comes back at its position with its articles', () async {
    final a = await categories.add(label: 'A', color: blue);
    final b = await categories.add(label: 'B', color: blue);
    await categories.add(label: 'C', color: blue);
    await lists.add('L');
    final list = (await lists.all()).single;
    await lists.addArticle(listId: list.id, label: 'Milk', category: b);

    final deleted = (await categories.remove(b.id))!;
    expect((await categories.all()).map((c) => c.label), ['A', 'C']);
    expect((await lists.all()).single.articles.single.category, isNull);

    await categories.restore(deleted);
    expect((await categories.all()).map((c) => c.label), ['A', 'B', 'C']);
    expect((await lists.all()).single.articles.single.category, b);
    expect(a.id, isNotEmpty);
  });

  test('a deleted card comes back linked to its lists', () async {
    final card = await cards.add(label: 'Store', code: '123', color: blue, format: CardFormat.ean13);
    await cards.add(label: 'Other', code: '456', color: blue, format: CardFormat.code128);
    await lists.add('L');
    final list = (await lists.all()).single;
    await lists.update(list.copyWith(cardId: card.id));

    final deleted = (await cards.remove(card.id))!;
    expect((await lists.all()).single.cardId, isNull);

    await cards.restore(deleted);
    expect((await cards.all()).map((c) => c.label), ['Store', 'Other']);
    expect((await cards.all()).first.format, CardFormat.ean13);
    expect((await lists.all()).single.cardId, card.id);
  });

  test('a deleted list comes back with its articles, a deleted article at its place', () async {
    await lists.add('First');
    await lists.add('Second');
    final [first, second] = await lists.all();
    await lists.addArticle(listId: first.id, label: 'Milk');
    await lists.addArticle(listId: first.id, label: 'Eggs');
    await lists.addArticle(listId: first.id, label: 'Bread');

    final deletedList = (await lists.remove(first.id))!;
    expect((await lists.all()).map((l) => l.label), ['Second']);
    await lists.restore(deletedList);
    expect((await lists.all()).map((l) => l.label), ['First', 'Second']);
    expect((await lists.all()).first.articles.map((a) => a.label), ['Milk', 'Eggs', 'Bread']);
    expect(second.id, isNotEmpty);

    final eggs = (await lists.all()).first.articles[1];
    final deletedArticle = (await lists.removeArticle(eggs.id))!;
    expect((await lists.all()).first.articles.map((a) => a.label), ['Milk', 'Bread']);
    await lists.restoreArticle(deletedArticle);
    expect((await lists.all()).first.articles.map((a) => a.label), ['Milk', 'Eggs', 'Bread']);
  });

  test('a deleted price comes back, and a price can be changed', () async {
    await prices.addManual(cents: 150);
    final price = (await prices.all()).single;
    await prices.update(price.copyWithCents(275));
    expect((await prices.all()).single.cents, 275);

    final deleted = (await prices.remove(price.id))!;
    expect(await prices.all(), isEmpty);
    await prices.restore(deleted);
    expect((await prices.all()).single.cents, 275);
  });

  test('restoring a backup with replace starts from an empty database', () async {
    await categories.add(label: 'Old', color: blue);
    await lists.add('Old list');
    final importer = DataImporter(db, DataChanges());

    await importer.importBackup({
      'categories': [
        {'label': 'New', 'color': 1},
      ],
      'articles': [
        {'id': 'l1', 'label': 'New list', 'card': '', 'articles': []},
      ],
    }, replace: true);

    expect((await categories.all()).map((c) => c.label), ['New']);
    expect((await lists.all()).map((l) => l.label), ['New list']);
  });
}
