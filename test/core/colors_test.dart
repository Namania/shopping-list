import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/core/database/app_database.dart';
import 'package:shopping_list/core/theme/app_theme.dart';
import 'package:shopping_list/core/theme/palette.dart';
import 'package:shopping_list/core/utils/colors.dart';
import 'package:shopping_list/features/cards/card_face.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('no invisible colour', () {
    test('a missing or transparent colour becomes the fallback, a translucent one opaque', () {
      expect(opaqueColor(null), fallbackItemColor);
      expect(opaqueColor(0x00000000), fallbackItemColor);
      expect(opaqueColor(0x0043A047), fallbackItemColor);
      expect(opaqueColor(0x8043A047), const Color(0xFF43A047));
      expect(opaqueColor(0xFF43A047), const Color(0xFF43A047));
    });

    test('a card of 1.3.x without colour gets one', () {
      final card = LoyaltyCard.fromMap({'label': 'Store', 'code': '1'}, fallbackId: 'x');
      expect(card.color, fallbackItemColor);
    });

    test('the database upgrade repairs the colours already stored', () async {
      sqfliteFfiInit();
      final dir = await Directory.systemTemp.createTemp('colors');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}/v2.db';

      final v2 = await AppDatabase.open(factory: databaseFactoryFfi, path: path, version: 2);
      await v2.insert('cards', {'id': 'a', 'label': 'No colour', 'code': '1', 'color': 0, 'position': 0});
      await v2.insert('cards', {
        'id': 'b',
        'label': 'Translucent',
        'code': '2',
        'color': 0x801E88E5,
        'position': 1,
      });
      await v2.insert('cards', {'id': 'c', 'label': 'Blue', 'code': '3', 'color': 0xFF1E88E5, 'position': 2});
      await v2.insert('categories', {'id': 'f', 'label': 'Fruits', 'color': 0, 'position': 0});
      await v2.close();

      final db = await AppDatabase.open(factory: databaseFactoryFfi, path: path);
      addTearDown(db.close);
      final rows = await db.query('cards', orderBy: 'position');
      expect([for (final r in rows) r['color']], [fallbackItemColor.toARGB32(), 0xFF1E88E5, 0xFF1E88E5]);
      expect((await CategoryRepository(db).all()).single.color, fallbackItemColor);
      expect((await CardRepository(db).all()).first.color, fallbackItemColor);
    });
  });

  group('colours close to the background get an outline', () {
    Future<BoxDecoration> faceOf(WidgetTester tester, Color color, Brightness brightness) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(Ambiance.warm, brightness),
          home: Scaffold(
            body: CardFace(label: 'Store', code: '123', color: color, format: CardFormat.code128),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final box = tester.widget<DecoratedBox>(
        find.descendant(of: find.byType(CardFace), matching: find.byType(DecoratedBox)).first,
      );
      return box.decoration as BoxDecoration;
    }

    testWidgets('a white card on the light theme, a black one on the dark theme', (tester) async {
      expect((await faceOf(tester, Colors.white, Brightness.light)).border, isNotNull);
      expect((await faceOf(tester, const Color(0xFF0A0A0A), Brightness.dark)).border, isNotNull);
    });

    testWidgets('a coloured card needs none', (tester) async {
      expect((await faceOf(tester, const Color(0xFF1E88E5), Brightness.light)).border, isNull);
      expect((await faceOf(tester, const Color(0xFF1E88E5), Brightness.dark)).border, isNull);
      expect((await faceOf(tester, Colors.white, Brightness.dark)).border, isNull);
    });
  });
}
