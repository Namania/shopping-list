import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list/features/article/data/datasources/article_remote_datasource.dart';
import 'package:shopping_list/features/article/data/repositories/article_repository_impl.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:shopping_list/features/article/domain/usecases/add_article_from_map.dart';
import 'package:shopping_list/features/article/domain/usecases/article_import.dart';
import 'package:shopping_list/features/article/domain/usecases/migrate_articles.dart';
import 'package:shopping_list/features/article/domain/usecases/remove_article_from_map.dart';
import 'package:shopping_list/features/article/domain/usecases/clear.dart';
import 'package:shopping_list/features/article/domain/usecases/get_all.dart';
import 'package:shopping_list/features/article/domain/usecases/toogle_article_done_state.dart';
import 'package:shopping_list/features/article/domain/usecases/update_article.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/calculator/data/datasources/calculator_remote_datasource.dart';
import 'package:shopping_list/features/calculator/data/repositories/calculator_repository_impl.dart';
import 'package:shopping_list/features/calculator/domain/repositories/calculator_repository.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_reset.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_subtract.dart';
import 'package:shopping_list/features/calculator/domain/usecases/get_value.dart';
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

import 'core/shared/cubit/theme_cubit.dart';
import 'features/calculator/domain/usecases/calculator_add.dart';

GetIt getIt = GetIt.instance;

Future<void> initDependencies() async {
  await EasyLocalization.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

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
    await prefs.setInt("calculator", 0);
  }

  getIt.registerLazySingleton(() => prefs);

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
    ..registerFactory<UpdateArticle>(() => UpdateArticle(getIt()))
    ..registerFactory<RemoveArticle>(() => RemoveArticle(getIt()))
    ..registerFactory<ToogleArticleDoneState>(() => ToogleArticleDoneState(getIt()))
    ..registerFactory<Clear>(() => Clear(getIt()))
    ..registerFactory<ArticleImport>(() => ArticleImport(getIt()))
    ..registerFactory<MigrateArticles>(() => MigrateArticles(getIt()))
    // bloc
    ..registerLazySingleton<ArticleBloc>(
      () => ArticleBloc(
        getAll: getIt(),
        addArticle: getIt(),
        updateArticle: getIt(),
        removeArticle: getIt(),
        toogleArticleDoneState: getIt(),
        clear: getIt(),
        articleImport: getIt(),
        migrateArticles: getIt(),
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
      () => CalculatorRemoteDatasourceImpl(getIt()),
    )
    // repositories
    ..registerCachedFactory<CalculatorRepository>(() => CalculatorRepositoryImpl(getIt()))
    // usecases
    ..registerFactory<GetValue>(() => GetValue(getIt()))
    ..registerFactory<CalculatorAdd>(() => CalculatorAdd(getIt()))
    ..registerFactory<CalculatorSubtract>(() => CalculatorSubtract(getIt()))
    ..registerFactory<CalculatorReset>(() => CalculatorReset(getIt()))
    // bloc
    ..registerLazySingleton<CalculatorBloc>(
      () => CalculatorBloc(
        getValue: getIt(),
        calculatorAdd: getIt(),
        calculatorSubtract: getIt(),
        calculatorReset: getIt(),
      ),
    );
}
