import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/lists/article.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';

class ListsCubit extends RepositoryCubit<List<ShoppingList>> {
  final ListRepository _repository;

  ListsCubit(this._repository, DataChanges changes) : super(const [], changes);

  @override
  Future<List<ShoppingList>> load() => _repository.all();

  ShoppingList? byId(String id) => state.where((l) => l.id == id).firstOrNull;

  List<Article> get allArticles => [for (final list in state) ...list.articles];

  // ---- lists ----

  /// Returns `false` when a list with this label already exists.
  Future<bool> add(String label) async {
    var added = false;
    await mutate(() async => added = await _repository.add(label));
    return added;
  }

  Future<void> update(ShoppingList list) => mutate(() => _repository.update(list));

  /// Removes a list and returns what [restore] needs to undo it.
  Future<DeletedList?> remove(String id) async {
    DeletedList? deleted;
    await mutate(() async => deleted = await _repository.remove(id));
    return deleted;
  }

  Future<void> restore(DeletedList deleted) => mutate(() => _repository.restore(deleted));

  Future<void> reorder(int oldIndex, int newIndex) => mutate(() => _repository.reorder(oldIndex, newIndex));

  /// Puts the lists in the order of [ids].
  Future<void> setOrder(List<String> ids) => mutate(() => _repository.setOrder(ids));

  /// Copies a list, articles unchecked; returns the copy's id.
  Future<String?> duplicate(String sourceId, String label) async {
    String? id;
    await mutate(() async => id = await _repository.duplicate(sourceId, label));
    return id;
  }

  /// Unchecks every article of a list.
  Future<void> restart(String listId) => mutate(() => _repository.restart(listId));

  // ---- articles ----

  /// Returns `false` when the list already has an article with this label.
  Future<bool> addArticle({required String listId, required String label, Category? category}) async {
    var added = false;
    await mutate(
      () async => added = await _repository.addArticle(listId: listId, label: label, category: category),
    );
    return added;
  }

  Future<void> updateArticle(Article article) => mutate(() => _repository.updateArticle(article));

  Future<void> toggleDone(String articleId) => mutate(() => _repository.toggleDone(articleId));

  /// Removes an article and returns what [restoreArticle] needs to undo it.
  Future<DeletedArticle?> removeArticle(String id) async {
    DeletedArticle? deleted;
    await mutate(() async => deleted = await _repository.removeArticle(id));
    return deleted;
  }

  Future<void> restoreArticle(DeletedArticle deleted) => mutate(() => _repository.restoreArticle(deleted));

  Future<void> clear(String listId, {bool onlyDone = false}) =>
      mutate(() => _repository.clear(listId, onlyDone: onlyDone));
}
