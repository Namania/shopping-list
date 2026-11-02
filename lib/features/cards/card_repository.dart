import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/database/app_database.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';
import 'package:uuid/uuid.dart';

/// What [CardRepository.remove] took away, so it can be put back.
class DeletedCard {
  final LoyaltyCard card;
  final int position;
  final List<String> linkedLists;

  const DeletedCard(this.card, {required this.position, required this.linkedLists});
}

class CardRepository {
  final Database db;
  final Uuid _uuid;

  CardRepository(this.db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  static const table = 'cards';

  Future<List<LoyaltyCard>> all() async {
    final rows = await db.query(table, orderBy: 'position');
    return rows.map(_fromRow).toList();
  }

  Future<LoyaltyCard> add({
    required String label,
    required String code,
    required Color color,
    required CardFormat format,
  }) => _insert(db, LoyaltyCard(id: _uuid.v4(), label: label, code: code, color: color, format: format));

  Future<void> update(LoyaltyCard card) => db.update(
    table,
    {'label': card.label, 'code': card.code, 'color': card.color.toARGB32(), 'format': card.format.name},
    where: 'id = ?',
    whereArgs: [card.id],
  );

  /// Lists linked to a removed card are unlinked (FK ON DELETE SET NULL).
  /// Returns what is needed to [restore] the card.
  Future<DeletedCard?> remove(String id) => db.transaction((txn) async {
    final rows = await txn.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final linked = await txn.query('lists', columns: ['id'], where: 'card_id = ?', whereArgs: [id]);
    await txn.delete(table, where: 'id = ?', whereArgs: [id]);
    return DeletedCard(
      _fromRow(rows.first),
      position: rows.first['position'] as int,
      linkedLists: linked.map((r) => r['id'] as String).toList(),
    );
  });

  Future<void> restore(DeletedCard deleted) => db.transaction((txn) async {
    await txn.makeRoomAt(table, deleted.position);
    await _insert(txn, deleted.card, position: deleted.position);
    for (final listId in deleted.linkedLists) {
      await txn.update('lists', {'card_id': deleted.card.id}, where: 'id = ?', whereArgs: [listId]);
    }
  });

  Future<void> reorder(int oldIndex, int newIndex) => db.reorder(table, oldIndex, newIndex);

  /// Adds the cards of a share / backup payload.
  Future<void> importAll(List<Map<String, dynamic>> maps) => db.transaction((txn) async {
    for (final map in maps) {
      await importOneIn(txn, map);
    }
  });

  /// Adds one card of a share / backup payload. A card is skipped when its
  /// id is already known or, unless [keepIds] is set, when one with the same
  /// label, code and color exists. Returns whether it was inserted.
  Future<bool> importOneIn(DatabaseExecutor txn, Map<String, dynamic> map, {bool keepIds = false}) async {
    final card = LoyaltyCard.fromMap(map, fallbackId: _uuid.v4());
    final duplicate = await txn.query(
      table,
      where: keepIds ? 'id = ?' : 'id = ? OR (label = ? AND code = ? AND color = ?)',
      whereArgs: keepIds ? [card.id] : [card.id, card.label, card.code, card.color.toARGB32()],
    );
    if (duplicate.isNotEmpty) return false;
    await _insert(txn, card);
    return true;
  }

  Future<LoyaltyCard> _insert(DatabaseExecutor txn, LoyaltyCard card, {int? position}) async {
    await txn.insert(table, {
      'id': card.id,
      'label': card.label,
      'code': card.code,
      'color': card.color.toARGB32(),
      'format': card.format.name,
      'position': position ?? await txn.nextPosition(table),
    });
    return card;
  }

  static LoyaltyCard _fromRow(Map<String, Object?> row) => LoyaltyCard(
    id: row['id'] as String,
    label: row['label'] as String,
    code: row['code'] as String,
    color: Color(row['color'] as int),
    format: CardFormat.fromName(row['format'] as String?),
  );
}
