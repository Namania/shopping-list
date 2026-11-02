import 'package:flutter/material.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';

class CardsCubit extends RepositoryCubit<List<LoyaltyCard>> {
  final CardRepository _repository;

  CardsCubit(this._repository, DataChanges changes) : super(const [], changes);

  @override
  Future<List<LoyaltyCard>> load() => _repository.all();

  LoyaltyCard? byId(String? id) => state.where((c) => c.id == id).firstOrNull;

  Future<void> add({
    required String label,
    required String code,
    required Color color,
    required CardFormat format,
  }) => mutate(() => _repository.add(label: label, code: code, color: color, format: format));

  Future<void> update(LoyaltyCard card) => mutate(() => _repository.update(card));

  /// Removes a card and returns what [restore] needs to undo it.
  Future<DeletedCard?> remove(String id) async {
    DeletedCard? deleted;
    await mutate(() async => deleted = await _repository.remove(id));
    return deleted;
  }

  Future<void> restore(DeletedCard deleted) => mutate(() => _repository.restore(deleted));

  Future<void> reorder(int oldIndex, int newIndex) => mutate(() => _repository.reorder(oldIndex, newIndex));
}
