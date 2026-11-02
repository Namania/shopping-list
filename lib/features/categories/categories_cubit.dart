import 'package:flutter/material.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/categories/category_repository.dart';

class CategoriesCubit extends RepositoryCubit<List<Category>> {
  final CategoryRepository _repository;

  CategoriesCubit(this._repository, DataChanges changes) : super(const [], changes);

  @override
  Future<List<Category>> load() => _repository.all();

  /// Whether another category already has this label and color.
  bool exists(String label, Color color, {String? exceptId}) =>
      state.any((c) => c.id != exceptId && c.label == label && c.color == color);

  Future<void> add(String label, Color color) => mutate(() => _repository.add(label: label, color: color));

  Future<void> update(Category category) => mutate(() => _repository.update(category));

  /// Removes a category and returns what [restore] needs to undo it.
  Future<DeletedCategory?> remove(String id) async {
    DeletedCategory? deleted;
    await mutate(() async => deleted = await _repository.remove(id));
    return deleted;
  }

  Future<void> restore(DeletedCategory deleted) => mutate(() => _repository.restore(deleted));

  Future<void> removeAll() => mutate(_repository.removeAll);

  Future<void> reorder(int oldIndex, int newIndex) => mutate(() => _repository.reorder(oldIndex, newIndex));
}
