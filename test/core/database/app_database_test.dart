import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/core/database/app_database.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/features/cards/card_repository.dart';

void main() {
  late Directory dir;

  setUp(() async {
    sqfliteFfiInit();
    dir = await Directory.systemTemp.createTemp('shopping_list_db');
  });

  tearDown(() => dir.delete(recursive: true));

  test('a v1 database (no card format) is upgraded in place', () async {
    final path = p.join(dir.path, 'v1.db');
    final v1 = await AppDatabase.open(factory: databaseFactoryFfi, path: path, version: 1);
    await v1.insert('cards', {'id': 'c1', 'label': 'Store', 'code': '123', 'color': 1, 'position': 0});
    await v1.close();

    final v2 = await AppDatabase.open(factory: databaseFactoryFfi, path: path);
    expect(await v2.getVersion(), AppDatabase.latestVersion);
    final card = (await CardRepository(v2).all()).single;
    expect(card.format, CardFormat.code128);

    await CardRepository(v2).update(card.copyWith(format: CardFormat.ean13));
    expect((await CardRepository(v2).all()).single.format, CardFormat.ean13);
    await v2.close();
  });
}
