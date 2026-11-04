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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final path = p.join(await getDatabasesPath(), 'demo.db');
  await deleteDatabase(path);
  final db = await AppDatabase.open(path: path);
  await db.transaction((txn) async {
    await _demo.restoreIn(txn);
    // Skip the migration of older versions' data: it would put back that
    // phone's own settings.
    await txn.insert('settings', {'key': 'legacy_migrated', 'value': '1'});
  });
  await db.close();
  // The page to show first (e.g. `/lists/courses`), written by the
  // screenshot script in a `demo_page` file next to the database.
  final page = File(p.join(p.dirname(path), 'demo_page'));
  runApp(
    await bootstrap(
      databasePath: path,
      initialLocation: page.existsSync() ? page.readAsStringSync().trim() : null,
    ),
  );
}

final _demo = DataDump({
  'categories': [
    for (final (i, (id, label, color)) in [
      ('fruits', 'Fruits et légumes', 0xFF43A047),
      ('bakery', 'Boulangerie', 0xFFC77B30),
      ('dairy', 'Crèmerie', 0xFFFBC02D),
      ('butcher', 'Boucherie', 0xFFE53935),
      ('grocery', 'Épicerie', 0xFF8E24AA),
      ('drinks', 'Boissons', 0xFF1E88E5),
      ('hygiene', 'Hygiène', 0xFF00ACC1),
    ].indexed)
      {'id': id, 'label': label, 'color': color, 'position': i},
  ],
  'cards': [
    {
      'id': 'marche',
      'label': 'Marché Frais',
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
      'label': 'Pharmacie du Port',
      'code': 'PDP-0042-7781',
      'color': 0xFF00838F,
      'format': 'code128',
      'position': 2,
    },
  ],
  'lists': [
    {'id': 'courses', 'label': 'Courses de la semaine', 'card_id': 'marche', 'position': 0},
    {'id': 'apero', 'label': 'Apéro samedi', 'card_id': 'superplus', 'position': 1},
    {'id': 'pharmacie', 'label': 'Pharmacie', 'card_id': 'pharma', 'position': 2},
    {'id': 'bbq', 'label': 'Barbecue', 'card_id': null, 'position': 3},
  ],
  'articles': [
    ..._articles('courses', [
      ('Tomates cerises', 'fruits', true),
      ('Bananes', 'fruits', true),
      ('Avocats', 'fruits', false),
      ('Courgettes', 'fruits', false),
      ('Baguette tradition', 'bakery', false),
      ('Yaourts nature', 'dairy', true),
      ('Comté', 'dairy', false),
      ('Œufs', 'dairy', false),
      ('Poulet fermier', 'butcher', false),
      ('Pâtes complètes', 'grocery', false),
      ('Café en grains', 'grocery', true),
      ('Eau pétillante', 'drinks', false),
      ('Dentifrice', 'hygiene', false),
      ('Bougies d\'anniversaire', null, false),
    ]),
    ..._articles('apero', [
      ('Chips', 'grocery', false),
      ('Olives', 'grocery', false),
      ('Saucisson', 'butcher', false),
      ('Tomates cerises', 'fruits', false),
      ('Jus de pomme', 'drinks', false),
      ('Pain de campagne', 'bakery', false),
    ]),
    ..._articles('pharmacie', [('Pansements', 'hygiene', false), ('Crème solaire', 'hygiene', false)]),
    ..._articles('bbq', [
      ('Merguez', 'butcher', true),
      ('Charbon', null, true),
      ('Salade', 'fruits', true),
      ('Citronnade', 'drinks', true),
    ]),
  ],
  'prices': [
    {'id': 'p1', 'list_id': 'courses', 'article_id': 'courses-0', 'cents': 349},
    {'id': 'p2', 'list_id': 'courses', 'article_id': 'courses-1', 'cents': 219},
    {'id': 'p3', 'list_id': 'courses', 'article_id': 'courses-5', 'cents': 265},
    {'id': 'p4', 'list_id': 'courses', 'article_id': 'courses-10', 'cents': 1290},
    {'id': 'p5', 'list_id': 'courses', 'article_id': null, 'cents': 450},
  ],
}, settings: const AppSettings(calculatorEnabled: true, uncategorizedFirst: false, languageCode: 'fr'));

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
