import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/backup/data_dump.dart';
import 'package:shopping_list/features/backup/restore_points.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/prices/price_repository.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';
import 'package:shopping_list/features/sharing/data_importer.dart';
import 'package:shopping_list/features/sharing/import_bundle.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late DataChanges changes;
  late Directory directory;
  late RestorePoints points;

  setUp(() async {
    db = await openTestDatabase();
    changes = DataChanges();
    directory = await Directory.systemTemp.createTemp('restore_points');
    points = RestorePoints(db, changes, directory);
  });

  tearDown(() async {
    await changes.dispose();
    await db.close();
    await directory.delete(recursive: true);
  });

  /// Two lists, a card, a category and an amount.
  Future<void> seed() async {
    final fruits = await CategoryRepository(db).add(label: 'Fruits', color: const Color(0xFF43A047));
    final card = await CardRepository(
      db,
    ).add(label: 'Store', code: '123', color: const Color(0xFF1E5BC6), format: CardFormat.ean13);
    final lists = ListRepository(db);
    await lists.add('Groceries');
    await lists.add('Party');
    final groceries = (await lists.all()).first;
    await lists.update(groceries.copyWith(cardId: card.id));
    await lists.addArticle(listId: groceries.id, label: 'Apples', category: fruits);
    final apples = (await lists.all()).first.articles.single;
    await PriceRepository(db).setForArticle(listId: groceries.id, articleId: apples.id, cents: 349);
    await SettingsRepository(db).save(const AppSettings(themeMode: ThemeMode.dark));
  }

  test('a dump restores the data exactly, amounts and order included', () async {
    await seed();
    final before = await DataDump.read(db);
    final json = jsonDecode(jsonEncode(before.toJson())) as Map<String, dynamic>;

    await ListRepository(db).add('Extra');
    await PriceRepository(db).clear();
    await db.transaction(DataDump.fromJson(json).restoreIn);

    final after = await DataDump.read(db);
    expect(after.rows, before.rows);
    expect(after.settings?.themeMode, ThemeMode.dark);
  });

  test('a backup file of this version is read back and can be merged', () async {
    await seed();
    final file = TransferFile.backup(await DataDump.read(db), DateTime(2026, 11, 4, 18, 42));
    final bundle = ImportBundle.fromJson(jsonDecode(file));
    expect(bundle.isBackup, isTrue);
    expect(bundle.createdAt, DateTime(2026, 11, 4, 18, 42));
    expect([for (final l in bundle.lists) l['label']], ['Groceries', 'Party']);

    final other = await openTestDatabase();
    addTearDown(other.close);
    await DataImporter(other, DataChanges()).add(bundle);
    final groceries = (await ListRepository(other).all()).first;
    expect(groceries.label, 'Groceries');
    expect(groceries.cardId, isNotNull);
    expect(groceries.articles.single.category?.label, 'Fruits');
  });

  test('replacing with a backup brings the amounts back', () async {
    await seed();
    final bundle = ImportBundle.fromJson(
      jsonDecode(TransferFile.backup(await DataDump.read(db), DateTime(2026))),
    );
    await PriceRepository(db).clear();
    await ListRepository(db).add('Extra');

    await DataImporter(db, changes).replaceWith(bundle);
    expect((await PriceRepository(db).all()).single.cents, 349);
    expect([for (final l in await ListRepository(db).all()) l.label], ['Groceries', 'Party']);
  });

  group('reading what is imported', () {
    test('a shared file of this version', () {
      final bundle = ImportBundle.fromJson(
        jsonDecode(
          TransferFile.share(
            const SharePayload(ShareKind.cards, [
              {'id': 'c1', 'label': 'Store', 'code': '1', 'color': 1},
            ]),
          ),
        ),
      );
      expect(bundle.cards.single['label'], 'Store');
      expect(bundle.isBackup, isFalse);
    });

    test('a bare list of older versions, its kind told by its items', () {
      expect(
        ImportBundle.fromJson([
          {'label': 'L', 'articles': []},
        ]).lists,
        hasLength(1),
      );
      expect(
        ImportBundle.fromJson([
          {'label': 'C', 'code': '1', 'color': 1},
        ]).cards,
        hasLength(1),
      );
      expect(
        ImportBundle.fromJson([
          {'label': 'Fruits', 'color': 1},
        ]).categories,
        hasLength(1),
      );
    });

    test('an old backup, with its settings', () {
      final bundle = ImportBundle.fromJson({
        'articles': [],
        'cubits': {'theme': 2, 'route': 1, 'calculator': 0, 'category': 0, 'lang': 'en'},
      });
      expect(bundle.isBackup, isTrue);
      expect(bundle.settings?.themeMode, ThemeMode.dark);
    });

    test('a link, alone or inside a message', () {
      final link = const SharePayload(ShareKind.categories, [
        {'label': 'Fruits', 'color': 1},
      ]).toDeepLink();
      expect(ImportBundle.fromLink(link)!.categories, hasLength(1));
      expect(ImportBundle.fromLink('Here you go: $link\nSee you!')!.categories, hasLength(1));
      expect(ImportBundle.fromLink('hello'), isNull);
    });

    test('anything else is refused', () {
      expect(() => ImportBundle.fromJson({'hello': 1}), throwsFormatException);
      expect(() => ImportBundle.fromJson('text'), throwsFormatException);
      expect(() => ImportBundle.fromJson({'tables': 1}), throwsFormatException);
    });

    test('only the ticked items are kept', () {
      final bundle = ImportBundle.fromJson([
        {'label': 'A', 'articles': []},
        {'label': 'B', 'articles': []},
      ]).only(lists: {1}, cards: {}, categories: {});
      expect([for (final l in bundle.lists) l['label']], ['B']);
    });
  });

  group('restore points', () {
    test('no daily copy of nothing, but one before an import', () async {
      expect(await points.take(RestorePointReason.daily), isNull);
      expect(await points.take(RestorePointReason.beforeImport), isNotNull);
    });

    test('one copy a day, and only the 7 most recent are kept', () async {
      await seed();
      final start = DateTime(2026, 11, 1, 9);
      for (var day = 0; day < 10; day++) {
        await points.takeDailyIfDue(now: start.add(Duration(days: day)));
        await points.takeDailyIfDue(now: start.add(Duration(days: day, hours: 2)));
      }
      final all = await points.all();
      expect(all, hasLength(RestorePoints.max));
      expect(all.first.date, start.add(const Duration(days: 9)));
      expect(all.every((p) => p.reason == RestorePointReason.daily), isTrue);
    });

    test('going back restores the data and keeps the current one as a copy', () async {
      await seed();
      final point = (await points.take(RestorePointReason.daily))!;
      await ListRepository(db).add('Extra');

      final settings = await points.restore(point);
      expect(settings?.themeMode, ThemeMode.dark);
      expect([for (final l in await ListRepository(db).all()) l.label], ['Groceries', 'Party']);
      final all = await points.all();
      expect(all.map((p) => p.reason), contains(RestorePointReason.beforeRestore));
    });
  });
}
