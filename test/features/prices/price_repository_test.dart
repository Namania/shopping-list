import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/prices/price_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late PriceRepository repo;
  late String listId;
  late String articleId;

  setUp(() async {
    db = await openTestDatabase();
    repo = PriceRepository(db);
    final lists = ListRepository(db);
    await lists.add('Groceries');
    listId = (await lists.all()).single.id;
    await lists.addArticle(listId: listId, label: 'Milk');
    articleId = (await lists.all()).single.articles.single.id;
  });

  tearDown(() => db.close());

  test('one price per article, replaced on re-entry', () async {
    await repo.setForArticle(listId: listId, articleId: articleId, cents: 150);
    await repo.setForArticle(listId: listId, articleId: articleId, cents: 175);

    final all = await repo.all();
    expect(all.single.cents, 175);
    expect(all.single.amount, 1.75);
  });

  test('clear by list and by kind', () async {
    await repo.setForArticle(listId: listId, articleId: articleId, cents: 150);
    await repo.addManual(listId: listId, cents: 200);
    await repo.addManual(listId: listId, cents: 300);

    await repo.clear(linked: true);
    expect((await repo.all()).map((p) => p.cents), [200, 300]);

    await repo.addManual(cents: 400);
    await repo.clear(listId: 'other');
    expect((await repo.all()).length, 3);

    await repo.clear(listId: listId, linked: false);
    expect((await repo.all()).single.listId, isNull);
  });

  test('remove and removeForArticle', () async {
    await repo.setForArticle(listId: listId, articleId: articleId, cents: 150);
    await repo.addManual(listId: listId, cents: 200);
    final manual = (await repo.all()).firstWhere((p) => p.articleId == null);

    await repo.removeForArticle(articleId);
    expect((await repo.all()).single.id, manual.id);

    await repo.remove(manual.id);
    expect(await repo.all(), isEmpty);
  });
}
