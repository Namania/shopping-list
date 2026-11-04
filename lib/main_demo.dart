import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/bootstrap.dart';
import 'package:shopping_list/core/database/app_database.dart';
import 'package:shopping_list/features/backup/data_dump.dart';
import 'package:shopping_list/features/settings/app_settings.dart';

/// The app on made-up data, for store and portfolio screenshots:
/// `flutter run -t lib/main_demo.dart`. It uses its own database, reset at
/// every launch, so the real one is never touched. Stores and items are
/// fictional, with fixed ids so a page can be opened first (see below).
///
/// The screenshot script writes two files next to the database: `demo_page`,
/// the page to show first (e.g. `/lists/courses`), and `demo_lang`, `fr`
/// (default) or `en` for the app and its data.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final path = p.join(await getDatabasesPath(), 'demo.db');
  String? read(String name) {
    final file = File(p.join(p.dirname(path), name));
    return file.existsSync() ? file.readAsStringSync().trim() : null;
  }

  final english = read('demo_lang') == 'en';
  await deleteDatabase(path);
  final db = await AppDatabase.open(path: path);
  await db.transaction((txn) async {
    await _demo(english).restoreIn(txn);
    // Skip the migration of older versions' data: it would put back that
    // phone's own settings.
    await txn.insert('settings', {'key': 'legacy_migrated', 'value': '1'});
  });
  await db.close();
  runApp(await bootstrap(databasePath: path, initialLocation: read('demo_page')));
}

/// The demo data, in French or in [english].
DataDump _demo(bool english) {
  String t(String fr, String en) => english ? en : fr;
  return DataDump({
    'categories': [
      for (final (i, (id, label, color)) in [
        ('fruits', t('Fruits et légumes', 'Fruit & veg'), 0xFF43A047),
        ('bakery', t('Boulangerie', 'Bakery'), 0xFFC77B30),
        ('dairy', t('Crèmerie', 'Dairy'), 0xFFFBC02D),
        ('butcher', t('Boucherie', 'Butcher'), 0xFFE53935),
        ('grocery', t('Épicerie', 'Pantry'), 0xFF8E24AA),
        ('drinks', t('Boissons', 'Drinks'), 0xFF1E88E5),
        ('hygiene', t('Hygiène', 'Toiletries'), 0xFF00ACC1),
      ].indexed)
        {'id': id, 'label': label, 'color': color, 'position': i},
    ],
    'cards': [
      {
        'id': 'marche',
        'label': t('Marché Frais', 'Fresh Market'),
        'code': '2501234567898',
        'color': 0xFF2E7D32,
        'format': 'ean13',
        'position': 0,
      },
      {
        'id': 'superplus',
        'label': 'Super Plus',
        'code': '4012345678901',
        'color': 0xFFD84315,
        'format': 'ean13',
        'position': 1,
      },
      {
        'id': 'pharma',
        'label': t('Pharmacie du Port', 'Harbour Pharmacy'),
        'code': t('PDP-0042-7781', 'HBP-0042-7781'),
        'color': 0xFF00838F,
        'format': 'code128',
        'position': 2,
      },
    ],
    'lists': [
      {
        'id': 'courses',
        'label': t('Courses de la semaine', 'Weekly groceries'),
        'card_id': 'marche',
        'position': 0,
      },
      {'id': 'apero', 'label': t('Apéro samedi', 'Saturday drinks'), 'card_id': 'superplus', 'position': 1},
      {'id': 'pharmacie', 'label': t('Pharmacie', 'Pharmacy'), 'card_id': 'pharma', 'position': 2},
      {'id': 'bbq', 'label': 'Barbecue', 'card_id': null, 'position': 3},
    ],
    'articles': [
      ..._articles('courses', [
        (t('Tomates cerises', 'Cherry tomatoes'), 'fruits', true),
        (t('Bananes', 'Bananas'), 'fruits', true),
        (t('Avocats', 'Avocados'), 'fruits', false),
        (t('Courgettes', 'Courgettes'), 'fruits', false),
        (t('Baguette tradition', 'Sourdough bread'), 'bakery', false),
        (t('Yaourts nature', 'Plain yoghurt'), 'dairy', true),
        (t('Comté', 'Cheddar'), 'dairy', false),
        (t('Œufs', 'Eggs'), 'dairy', false),
        (t('Poulet fermier', 'Free-range chicken'), 'butcher', false),
        (t('Pâtes complètes', 'Wholewheat pasta'), 'grocery', false),
        (t('Café en grains', 'Coffee beans'), 'grocery', true),
        (t('Eau pétillante', 'Sparkling water'), 'drinks', false),
        (t('Dentifrice', 'Toothpaste'), 'hygiene', false),
        (t('Bougies d\'anniversaire', 'Birthday candles'), null, false),
      ]),
      ..._articles('apero', [
        (t('Chips', 'Crisps'), 'grocery', false),
        (t('Olives', 'Olives'), 'grocery', false),
        (t('Saucisson', 'Salami'), 'butcher', false),
        (t('Tomates cerises', 'Cherry tomatoes'), 'fruits', false),
        (t('Jus de pomme', 'Apple juice'), 'drinks', false),
        (t('Pain de campagne', 'Country loaf'), 'bakery', false),
      ]),
      ..._articles('pharmacie', [
        (t('Pansements', 'Plasters'), 'hygiene', false),
        (t('Crème solaire', 'Sunscreen'), 'hygiene', false),
      ]),
      ..._articles('bbq', [
        (t('Merguez', 'Sausages'), 'butcher', true),
        (t('Charbon', 'Charcoal'), null, true),
        (t('Salade', 'Lettuce'), 'fruits', true),
        (t('Citronnade', 'Lemonade'), 'drinks', true),
      ]),
    ],
    'prices': [
      {'id': 'p1', 'list_id': 'courses', 'article_id': 'courses-0', 'cents': 349},
      {'id': 'p2', 'list_id': 'courses', 'article_id': 'courses-1', 'cents': 219},
      {'id': 'p3', 'list_id': 'courses', 'article_id': 'courses-5', 'cents': 265},
      {'id': 'p4', 'list_id': 'courses', 'article_id': 'courses-10', 'cents': 1290},
      {'id': 'p5', 'list_id': 'courses', 'article_id': null, 'cents': 450},
    ],
  }, settings: AppSettings(calculatorEnabled: true, uncategorizedFirst: false, languageCode: t('fr', 'en')));
}

/// Articles of [listId], with ids `<listId>-<position>`.
List<Map<String, Object?>> _articles(String listId, List<(String, String?, bool)> articles) => [
  for (final (i, (label, category, done)) in articles.indexed)
    {
      'id': '$listId-$i',
      'list_id': listId,
      'label': label,
      'category_id': category,
      'done': done ? 1 : 0,
      'position': i,
    },
];
