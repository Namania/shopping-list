import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list/features/article/data/datasources/article_remote_datasource.dart';
import 'package:shopping_list/features/article/data/repositories/article_repository_impl.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:shopping_list/features/article/domain/usecases/add_article_from_map.dart';
import 'package:shopping_list/features/article/domain/usecases/add_list.dart';
import 'package:shopping_list/features/article/domain/usecases/article_import.dart';
import 'package:shopping_list/features/article/domain/usecases/migrate_article_to_multiple_list.dart';
import 'package:shopping_list/features/article/domain/usecases/migrate_articles.dart';
import 'package:shopping_list/features/article/domain/usecases/remove_article_from_map.dart';
import 'package:shopping_list/features/article/domain/usecases/clear.dart';
import 'package:shopping_list/features/article/domain/usecases/get_all.dart';
import 'package:shopping_list/features/article/domain/usecases/remove_list.dart';
import 'package:shopping_list/features/article/domain/usecases/toogle_article_done_state.dart';
import 'package:shopping_list/features/article/domain/usecases/update_article.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/calculator/data/datasources/calculator_remote_datasource.dart';
import 'package:shopping_list/features/calculator/data/repositories/calculator_repository_impl.dart';
import 'package:shopping_list/features/calculator/domain/repositories/calculator_repository.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_add.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_add_without_article.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_get_all_with_article.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_get_all_without_article.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_reset.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_reset_with.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_reset_without_article.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_subtract.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_get_all.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_subtract_without_article.dart';
import 'package:shopping_list/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:shopping_list/features/cards/data/datasources/card_remote_datasource.dart';
import 'package:shopping_list/features/cards/data/repositories/card_repository_impl.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';
import 'package:shopping_list/features/cards/domain/usecases/add_card.dart';
import 'package:shopping_list/features/cards/domain/usecases/card_get_all.dart';
import 'package:shopping_list/features/cards/domain/usecases/card_import.dart';
import 'package:shopping_list/features/cards/domain/usecases/remove_card.dart';
import 'package:shopping_list/features/cards/domain/usecases/rerange.dart';
import 'package:shopping_list/features/cards/domain/usecases/update_card.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/category/data/datasources/category_remote_datasource.dart';
import 'package:shopping_list/features/category/data/repositories/category_repository_impl.dart';
import 'package:shopping_list/features/category/domain/repositories/category_repository.dart';
import 'package:shopping_list/features/category/domain/usecases/add_category_from_map.dart';
import 'package:shopping_list/features/category/domain/usecases/category_import.dart';
import 'package:shopping_list/features/category/domain/usecases/clear.dart';
import 'package:shopping_list/features/category/domain/usecases/get_all_category.dart';
import 'package:shopping_list/features/category/domain/usecases/remove_category_from_map.dart';
import 'package:shopping_list/features/category/domain/usecases/rerange.dart';
import 'package:shopping_list/features/category/domain/usecases/update_category.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';
import 'package:uuid/uuid.dart';

import 'core/shared/cubit/theme_cubit.dart';

GetIt getIt = GetIt.instance;

Future<void> initDependencies() async {
  await EasyLocalization.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey("articles") || prefs.getString("articles") == "") {
    await prefs.setString("articles", "[]");
  }
  if (!prefs.containsKey("cards") || prefs.getString("cards") == "") {
    await prefs.setString("cards", "[]");
  }
  if (!prefs.containsKey("categories") || prefs.getString("categories") == "") {
    await prefs.setString("categories", "[]");
  }
  if (!prefs.containsKey("calculator")) {
    await prefs.setString("calculator", "[]");
  }
  if (!prefs.containsKey("calculator_without_article")) {
    await prefs.setString("calculator_without_article", "[]");
  }

  getIt.registerLazySingleton(() => prefs);

  Uuid uuid = Uuid();
  getIt.registerLazySingleton(() => uuid);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
      kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  getIt.registerLazySingleton(() => ThemeCubit());
  
  initArticle();
  initCard();
  initCategory();
  initCalculator();
}

void initArticle() {
  getIt
    // Datasource
    ..registerFactory<ArticleRemoteDatasource>(
      () => ArticleRemoteDatasourceImpl(getIt()),
    )
    // repositories
    ..registerCachedFactory<ArticleRepository>(() => ArticleRepositoryImpl(getIt()))
    // usecases
    ..registerFactory<GetAll>(() => GetAll(getIt()))
    ..registerFactory<AddArticle>(() => AddArticle(getIt()))
    ..registerFactory<AddList>(() => AddList(getIt()))
    ..registerFactory<UpdateArticle>(() => UpdateArticle(getIt()))
    ..registerFactory<RemoveArticle>(() => RemoveArticle(getIt()))
    ..registerFactory<RemoveList>(() => RemoveList(getIt()))
    ..registerFactory<ToogleArticleDoneState>(() => ToogleArticleDoneState(getIt()))
    ..registerFactory<Clear>(() => Clear(getIt()))
    ..registerFactory<ArticleImport>(() => ArticleImport(getIt()))
    ..registerFactory<MigrateArticles>(() => MigrateArticles(getIt()))
    ..registerFactory<MigrateArticleToMultipleList>(() => MigrateArticleToMultipleList(getIt()))
    // bloc
    ..registerLazySingleton<ArticleBloc>(
      () => ArticleBloc(
        getAll: getIt(),
        addArticle: getIt(),
        addList: getIt(),
        updateArticle: getIt(),
        removeArticle: getIt(),
        removeList: getIt(),
        toogleArticleDoneState: getIt(),
        clear: getIt(),
        articleImport: getIt(),
        migrateArticles: getIt(),
        migrateToMultipleList: getIt(),
      ),
    );
}

void initCard() {
  getIt
    // Datasource
    ..registerFactory<CardRemoteDatasource>(
      () => CardRemoteDatasourceImpl(getIt()),
    )
    // repositories
    ..registerCachedFactory<CardRepository>(() => CardRepositoryImpl(getIt()))
    // usecases
    ..registerFactory<CardGetAll>(() => CardGetAll(getIt()))
    ..registerFactory<AddCard>(() => AddCard(getIt()))
    ..registerFactory<UpdateCard>(() => UpdateCard(getIt()))
    ..registerFactory<RemoveCard>(() => RemoveCard(getIt()))
    ..registerFactory<CardImport>(() => CardImport(getIt()))
    ..registerFactory<RerangeCard>(() => RerangeCard(getIt()))
    // bloc
    ..registerLazySingleton<CardBloc>(
      () => CardBloc(
        cardGetAll: getIt(),
        addCard: getIt(),
        updateCard: getIt(),
        removeCard: getIt(),
        cardImport: getIt(),
        rerangeCard: getIt(),
      ),
    );
}

void initCategory() {
  getIt
    // Datasource
    ..registerFactory<CategoryRemoteDatasource>(
      () => CategoryRemoteDatasourceImpl(getIt()),
    )
    // repositories
    ..registerCachedFactory<CategoryRepository>(() => CategoryRepositoryImpl(getIt()))
    // usecases
    ..registerFactory<GetAllCategory>(() => GetAllCategory(getIt()))
    ..registerFactory<AddCategory>(() => AddCategory(getIt()))
    ..registerFactory<UpdateCategory>(() => UpdateCategory(getIt()))
    ..registerFactory<RemoveCategory>(() => RemoveCategory(getIt()))
    ..registerFactory<CategoryImport>(() => CategoryImport(getIt()))
    ..registerFactory<ClearCategory>(() => ClearCategory(getIt()))
    ..registerFactory<RerangeCategory>(() => RerangeCategory(getIt()))
    // bloc
    ..registerLazySingleton<CategoryBloc>(
      () => CategoryBloc(
        getAll: getIt(),
        addCategory: getIt(),
        updateCategory: getIt(),
        removeCategory: getIt(),
        categoryImport: getIt(),
        clearCategory: getIt(),
        rerangeCategory: getIt(),
      ),
    );
}

void initCalculator() {
  getIt
    // Datasource
    ..registerFactory<CalculatorRemoteDatasource>(
      () => CalculatorRemoteDatasourceImpl(getIt(), getIt()),
    )
    // repositories
    ..registerCachedFactory<CalculatorRepository>(() => CalculatorRepositoryImpl(getIt()))
    // usecases
    ..registerFactory<CalculatorGetAll>(() => CalculatorGetAll(getIt()))
    ..registerFactory<CalculatorGetAllWithArticle>(() => CalculatorGetAllWithArticle(getIt()))
    ..registerFactory<CalculatorGetAllWithoutArticle>(() => CalculatorGetAllWithoutArticle(getIt()))
    ..registerFactory<CalculatorAdd>(() => CalculatorAdd(getIt()))
    ..registerFactory<CalculatorAddWithoutArticle>(() => CalculatorAddWithoutArticle(getIt()))
    ..registerFactory<CalculatorSubtract>(() => CalculatorSubtract(getIt()))
    ..registerFactory<CalculatorSubtractWithoutArticle>(() => CalculatorSubtractWithoutArticle(getIt()))
    ..registerFactory<CalculatorReset>(() => CalculatorReset(getIt()))
    ..registerFactory<CalculatorResetWith>(() => CalculatorResetWith(getIt()))
    ..registerFactory<CalculatorResetWithoutArticle>(() => CalculatorResetWithoutArticle(getIt()))
    // bloc
    ..registerLazySingleton<CalculatorBloc>(
      () => CalculatorBloc(
        getAll: getIt(),
        getAllWithArticle: getIt(),
        getAllWithoutArticle: getIt(),
        calculatorAdd: getIt(),
        calculatorAddWithoutArticle: getIt(),
        calculatorSubtract: getIt(),
        calculatorSubtractWithoutArticle: getIt(),
        calculatorReset: getIt(),
        calculatorResetWith: getIt(),
        calculatorResetWithoutArticle: getIt(),
      ),
    );
}
