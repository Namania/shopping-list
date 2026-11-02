import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late CardRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = CardRepository(db);
  });

  tearDown(() => db.close());

  test('add, update and remove', () async {
    final card = await repo.add(
      label: 'Store',
      code: '123',
      color: const Color(0xFF2196F3),
      format: CardFormat.code128,
    );
    await repo.update(card.copyWith(code: '456'));
    expect((await repo.all()).single.code, '456');

    await repo.remove(card.id);
    expect(await repo.all(), isEmpty);
  });

  test('removing a card unlinks only the lists that used it', () async {
    final card = await repo.add(
      label: 'Store',
      code: '123',
      color: const Color(0xFF2196F3),
      format: CardFormat.code128,
    );
    final other = await repo.add(
      label: 'Other',
      code: '789',
      color: const Color(0xFFF44336),
      format: CardFormat.code128,
    );
    final lists = ListRepository(db);
    await lists.add('A');
    await lists.add('B');
    final [a, b] = await lists.all();
    await lists.update(a.copyWith(cardId: card.id));
    await lists.update(b.copyWith(cardId: other.id));

    await repo.remove(card.id);

    final [a2, b2] = await lists.all();
    expect(a2.cardId, isNull);
    expect(b2.cardId, other.id);
  });

  test('importAll keeps ids, fills missing ones and skips duplicates', () async {
    await repo.importAll([
      {'id': 'c1', 'label': 'Store', 'code': '123', 'color': const Color(0xFF2196F3).toARGB32()},
      {'label': 'Legacy', 'code': '999'},
      {'id': 'c1', 'label': 'Store', 'code': '123', 'color': const Color(0xFF2196F3).toARGB32()},
      {'label': 'Store', 'code': '123', 'color': const Color(0xFF2196F3).toARGB32()},
    ]);

    final all = await repo.all();
    expect(all.map((c) => c.label), ['Store', 'Legacy']);
    expect(all.first.id, 'c1');
    expect(all.last.id, isNotEmpty);
  });
}
