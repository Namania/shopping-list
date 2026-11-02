import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/prices/price.dart';
import 'package:shopping_list/features/prices/price_repository.dart';

class PricesCubit extends RepositoryCubit<List<Price>> {
  final PriceRepository _repository;

  PricesCubit(this._repository, DataChanges changes) : super(const [], changes);

  @override
  Future<List<Price>> load() => _repository.all();

  /// Prices of one list, or of every list when [listId] is `null`.
  List<Price> forList(String? listId) =>
      listId == null ? state : state.where((p) => p.listId == listId).toList();

  double total(String? listId) => forList(listId).fold(0, (sum, p) => sum + p.cents) / 100;

  Future<void> setForArticle({required String listId, required String articleId, required int cents}) =>
      mutate(() => _repository.setForArticle(listId: listId, articleId: articleId, cents: cents));

  Future<void> addManual({required int cents, String? listId}) =>
      mutate(() => _repository.addManual(cents: cents, listId: listId));

  Future<void> update(Price price) => mutate(() => _repository.update(price));

  /// Removes a price and returns what [restore] needs to undo it.
  Future<Price?> remove(String id) async {
    Price? deleted;
    await mutate(() async => deleted = await _repository.remove(id));
    return deleted;
  }

  Future<void> restore(Price price) => mutate(() => _repository.restore(price));

  Future<void> removeForArticle(String articleId) => mutate(() => _repository.removeForArticle(articleId));

  Future<void> clear({String? listId, bool? linked}) =>
      mutate(() => _repository.clear(listId: listId, linked: linked));
}
