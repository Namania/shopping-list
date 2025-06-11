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
import 'package:shopping_list/features/article/domain/usecases/article_import.dart';
import 'package:shopping_list/features/article/domain/usecases/remove_article_from_map%20copy.dart';
import 'package:shopping_list/features/article/domain/usecases/clear.dart';
import 'package:shopping_list/features/article/domain/usecases/get_all.dart';
import 'package:shopping_list/features/article/domain/usecases/toogle_article_done_state.dart';
import 'package:shopping_list/features/article/domain/usecases/update_article.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/cards/data/datasources/card_remote_datasource.dart';
import 'package:shopping_list/features/cards/data/repositories/card_repository_impl.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';
import 'package:shopping_list/features/cards/domain/usecases/add_card.dart';
import 'package:shopping_list/features/cards/domain/usecases/card_get_all.dart';
import 'package:shopping_list/features/cards/domain/usecases/card_import.dart';
import 'package:shopping_list/features/cards/domain/usecases/remove_card%20copy.dart';
import 'package:shopping_list/features/cards/domain/usecases/update_card.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';

import 'core/shared/cubit/theme_cubit.dart';

GetIt getIt = GetIt.instance;

Future<void> initDependencies() async {
  await EasyLocalization.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey("articles") || prefs.getString("articles") == "") {
    await prefs.setString("articles", "[]");
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
    // bloc
    ..registerLazySingleton<CardBloc>(
      () => CardBloc(
        cardGetAll: getIt(),
        addCard: getIt(),
        updateCard: getIt(),
        removeCard: getIt(),
        cardImport: getIt(),
      ),
    );
}
