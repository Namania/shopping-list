import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';
import 'package:shopping_list/features/sharing/data_importer.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late DataChanges changes;
  late DataImporter importer;
  late int notifications;

  setUp(() async {
    db = await openTestDatabase();
    changes = DataChanges();
    notifications = 0;
    changes.stream.listen((_) => notifications++);
    importer = DataImporter(db, changes);
  });

  tearDown(() async {
    await changes.dispose();
    await db.close();
  });

  final fruits = {'label': 'Fruits', 'color': 1};
  final card = {'id': 'c1', 'label': 'Store', 'code': '123', 'color': 2};
  Map<String, dynamic> list({String card = ''}) => {
    'id': 'l1',
    'label': 'Groceries',
    'card': card,
    'articles': [
      {'id': 'a1', 'label': 'Apples', 'category': fruits, 'done': false},
    ],
  };

  test('a backup restores cards before lists so the links survive', () async {
    final restored = await importer.importBackup({
      'articles': [list(card: 'c1')],
      'cards': [card],
      'categories': [fruits],
      'settings': {...const AppSettings(themeMode: ThemeMode.dark).toMap(), 'lang': 'fr'},
    });

    final imported = (await ListRepository(db).all()).single;
    expect(imported.cardId, 'c1');
    expect(imported.articles.single.category?.label, 'Fruits');
    expect(restored.settings?.themeMode, ThemeMode.dark);
    expect(restored.lang, 'fr');
    expect((await SettingsRepository(db).load()).themeMode, ThemeMode.dark);
    await Future<void>.delayed(Duration.zero);
    expect(notifications, 1);
  });

  test('a 1.3.x backup with "cubits" settings is read', () async {
    final restored = await importer.importBackup({
      'articles': [],
      'cubits': {'theme': 2, 'route': 1, 'calculator': 0, 'category': 0, 'lang': 'en'},
    });
    expect(
      restored.settings,
      const AppSettings(themeMode: ThemeMode.dark, startRoute: StartRoute.lists, calculatorEnabled: true),
    );
    expect(restored.lang, 'en');
  });

  test('a malformed backup leaves nothing behind', () async {
    await expectLater(
      importer.importBackup({
        'categories': [fruits],
        'articles': [
          {'id': 'l1', 'label': 'No articles key'},
        ],
      }),
      throwsA(isA<TypeError>()),
    );
    expect(await CategoryRepository(db).all(), isEmpty);
    expect(await ListRepository(db).all(), isEmpty);
    expect(notifications, 0);
  });

  test('a shared payload is imported by kind', () async {
    await importer.importShared(ShareKind.categories, [fruits]);
    await importer.importShared(ShareKind.cards, [card]);
    await importer.importShared(ShareKind.lists, [list(card: 'c1')]);

    expect((await CategoryRepository(db).all()).single.label, 'Fruits');
    expect((await CardRepository(db).all()).single.id, 'c1');
    final imported = (await ListRepository(db).all()).single;
    expect(imported.id, isNot('l1'), reason: 'shared lists get a fresh id');
    expect(imported.cardId, 'c1');
    await Future<void>.delayed(Duration.zero);
    expect(notifications, 3);
  });
}
