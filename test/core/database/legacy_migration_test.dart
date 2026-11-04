import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/core/database/legacy_migration.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/prices/price_repository.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';

import '../../helpers/test_database.dart';

/// Encodes a collection the way `shared_preferences` held it: a JSON array of
/// JSON-encoded strings.
String legacyList(List<Map<String, dynamic>> items) => jsonEncode(items.map(jsonEncode).toList());

void main() {
  late Database db;

  setUp(() async => db = await openTestDatabase());
  tearDown(() => db.close());

  final fruits = {'label': 'Fruits', 'color': const Color(0xFF4CAF50).toARGB32()};

  test('imports every collection and the settings, then marks itself done', () async {
    final data = LegacyData(
      categories: legacyList([fruits]),
      cards: legacyList([
        {'id': 'card1', 'label': 'Store', 'code': '123', 'color': const Color(0xFF2196F3).toARGB32()},
        {'label': 'No id', 'code': '456'},
      ]),
      lists: legacyList([
        {
          'id': 'list1',
          'label': 'Groceries',
          'card': 'card1',
          'articles': [
            {'id': 'a1', 'label': 'Apples', 'category': fruits, 'done': true},
            {
              'id': 'a2',
              'label': 'Soap',
              'category': {'label': 'Other', 'color': 1},
              'done': false,
            },
          ],
        },
      ]),
      prices: legacyList([
        {'id_list': 'list1', 'id_article': 'a1', 'price': 150.0},
        {'id_list': 'list1', 'id_article': 'missing', 'price': 999.0},
      ]),
      manualPrices: legacyList([
        {'id_list': 'list1', 'id_article': 'random', 'price': 200.0},
        {'id_list': '', 'id_article': 'random2', 'price': 300.0},
      ]),
      theme: {'theme_mode': ThemeMode.dark.index},
      startRoute: {'setting_router': 1},
      categoryPosition: {'setting_default_category_position': 1},
      calculator: {'setting_enable_calculator': 0},
      language: 'en_US',
    );

    expect(await LegacyMigration.isDone(db), isFalse);
    final report = await LegacyMigration.run(db, data);
    expect(await LegacyMigration.isDone(db), isTrue);
    expect(report.complete, isTrue);
    expect((report.categories, report.cards, report.lists, report.articles, report.prices), (1, 2, 1, 2, 3));

    expect((await CategoryRepository(db).all()).single.label, 'Fruits');
    expect((await CardRepository(db).all()).map((c) => c.label), ['Store', 'No id']);

    final list = (await ListRepository(db).all()).single;
    expect(list.id, 'list1');
    expect(list.cardId, 'card1');
    expect(list.articles.map((a) => a.label), ['Apples', 'Soap']);
    expect(list.articles.first.category?.label, 'Fruits');
    expect(list.articles.first.done, isTrue);
    expect(list.articles.last.category, isNull);

    final prices = await PriceRepository(db).all();
    expect(prices.map((p) => p.cents), [150, 200, 300]);
    expect(prices.first.articleId, 'a1');
    expect(prices[1].articleId, isNull);
    expect(prices[1].listId, 'list1');
    expect(prices.last.listId, isNull);

    expect(
      await SettingsRepository(db).load(),
      const AppSettings(
        themeMode: ThemeMode.dark,
        startRoute: StartRoute.lists,
        uncategorizedFirst: false,
        calculatorEnabled: true,
        languageCode: 'en',
      ),
    );
  });

  test('wraps the flat article list of versions < 1.2 in a default list', () async {
    await LegacyMigration.run(
      db,
      LegacyData(
        lists: legacyList([
          {'label': 'Milk', 'category': fruits, 'done': false},
        ]),
      ),
    );

    final list = (await ListRepository(db).all()).single;
    expect(list.label, 'Default');
    expect(list.articles.single.label, 'Milk');
    expect(list.articles.single.id, isNotEmpty);
  });

  test('a fresh install gets default settings', () async {
    final report = await LegacyMigration.run(db, const LegacyData());
    expect(report.complete, isTrue);
    expect(await SettingsRepository(db).load(), const AppSettings());
    expect(await ListRepository(db).all(), isEmpty);
  });

  test('a list linked to a card that no longer exists is kept, unlinked', () async {
    await LegacyMigration.run(
      db,
      LegacyData(
        lists: legacyList([
          {'id': 'l1', 'label': 'Shared', 'card': 'card-from-another-phone', 'articles': []},
        ]),
      ),
    );

    final list = (await ListRepository(db).all()).single;
    expect(list.label, 'Shared');
    expect(list.cardId, isNull);
  });

  test('the same shared list imported twice keeps both copies and their articles', () async {
    final copy = {
      'label': 'Shared',
      'card': '',
      'articles': [
        {'id': 'same-article', 'label': 'Milk', 'category': fruits, 'done': false},
      ],
    };
    final report = await LegacyMigration.run(
      db,
      LegacyData(
        lists: legacyList([
          {'id': 'l1', ...copy},
          {'id': 'l2', ...copy},
        ]),
        prices: legacyList([
          {'id_list': 'l2', 'id_article': 'same-article', 'price': 100.0},
        ]),
      ),
    );

    expect(report.complete, isTrue);
    expect(report.articles, 2);
    final lists = await ListRepository(db).all();
    expect(lists.map((l) => l.articles.single.label), ['Milk', 'Milk']);
    expect(lists.first.articles.single.id, 'same-article');
    expect(lists.last.articles.single.id, isNot('same-article'));
    expect((await PriceRepository(db).all()).single.articleId, 'same-article');
  });

  test('identical cards with different ids are both kept', () async {
    final card = {'label': 'Store', 'code': '123', 'color': 1};
    await LegacyMigration.run(
      db,
      LegacyData(
        cards: legacyList([
          {'id': 'c1', ...card},
          {'id': 'c2', ...card},
        ]),
        lists: legacyList([
          {'id': 'l1', 'label': 'A', 'card': 'c2', 'articles': []},
        ]),
      ),
    );

    expect((await CardRepository(db).all()).map((c) => c.id), ['c1', 'c2']);
    expect((await ListRepository(db).all()).single.cardId, 'c2');
  });

  test('a duplicated price for one article is recorded once', () async {
    final report = await LegacyMigration.run(
      db,
      LegacyData(
        lists: legacyList([
          {
            'id': 'l1',
            'label': 'A',
            'card': '',
            'articles': [
              {'id': 'a1', 'label': 'Milk', 'category': fruits, 'done': true},
            ],
          },
        ]),
        prices: legacyList([
          {'id_list': 'l1', 'id_article': 'a1', 'price': 100.0},
          {'id_list': 'l1', 'id_article': 'a1', 'price': 200.0},
        ]),
      ),
    );

    expect(report.complete, isTrue);
    expect(report.prices, 1);
    expect((await PriceRepository(db).all()).single.cents, 100);
  });

  test('a malformed entry is skipped and reported, the rest is imported', () async {
    final report = await LegacyMigration.run(
      db,
      LegacyData(
        categories: legacyList([
          fruits,
          {'label': null, 'color': 'red'},
        ]),
        lists: legacyList([
          {'id': 'l1', 'label': 'A', 'card': '', 'articles': []},
          {'id': 'l2', 'articles': []},
        ]),
      ),
    );

    expect(report.complete, isFalse);
    expect(report.skipped, 2);
    expect(report.categories, 1);
    expect(report.lists, 1);
    expect(await LegacyMigration.isDone(db), isTrue);
    expect((await ListRepository(db).all()).single.label, 'A');
  });

  test('a corrupt store skips only that collection', () async {
    final report = await LegacyMigration.run(
      db,
      LegacyData(
        categories: 'not json',
        lists: legacyList([
          {'id': 'l1', 'label': 'A', 'card': '', 'articles': []},
        ]),
      ),
    );

    expect(report.skipped, 1);
    expect(report.lists, 1);
    expect(await LegacyMigration.isDone(db), isTrue);
    expect((await ListRepository(db).all()).single.label, 'A');
  });

  test('a malformed article is skipped without losing the others', () async {
    final report = await LegacyMigration.run(
      db,
      LegacyData(
        lists: legacyList([
          {
            'id': 'l1',
            'label': 'A',
            'card': '',
            'articles': [
              {'id': 'a1', 'label': 'Milk', 'category': fruits, 'done': false},
              {'id': 'a2', 'label': 'Broken', 'category': null, 'done': false},
              {'id': 'a3', 'label': 'Eggs', 'category': fruits, 'done': false},
            ],
          },
        ]),
      ),
    );

    expect(report.skipped, 1);
    expect(report.articles, 2);
    expect((await ListRepository(db).all()).single.articles.map((a) => a.label), ['Milk', 'Eggs']);
  });

  test('a linked price belongs to the list of its article even without a list id', () async {
    await LegacyMigration.run(
      db,
      LegacyData(
        lists: legacyList([
          {
            'id': 'l1',
            'label': 'A',
            'card': '',
            'articles': [
              {'id': 'a1', 'label': 'Milk', 'category': fruits, 'done': true},
            ],
          },
        ]),
        prices: legacyList([
          {'id_list': '', 'id_article': 'a1', 'price': 250.0},
        ]),
      ),
    );

    final price = (await PriceRepository(db).all()).single;
    expect(price.listId, 'l1');
    expect(price.articleId, 'a1');
  });
}
