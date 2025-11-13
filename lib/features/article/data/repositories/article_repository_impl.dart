import 'package:shopping_list/features/article/data/datasources/article_remote_datasource.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDatasource articleRemoteDatasource;

  ArticleRepositoryImpl(this.articleRemoteDatasource);

  @override
  Future<Either<Failure, List<ArticleListModel>>> getAll() async {
    try {
      return Right(await articleRemoteDatasource.getAll());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>> addArticle({
    required String id,
    required ArticleModel article,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.addArticle(id: id, article: article),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>> addList({
    required ArticleListModel articleList,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.addList(articleList: articleList),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>> removeArticle({
    required String id,
    required ArticleModel article,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.removeArticle(id: id, article: article),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>> removeList({
    required ArticleListModel articleList,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.removeList(articleList: articleList),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>> toogleArticleDoneState({
    required String id,
    required ArticleModel article,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.toogleArticleDoneState(
          id: id,
          article: article,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>> clear({
    required String id,
    required bool allArticle,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.clear(id: id, allArticle: allArticle),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>> articleImport({
    required String json,
    required CategoryModel defaultCategory,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.articleImport(
          json: json,
          defaultCategory: defaultCategory,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>> updateArticle({
    required String id,
    required ArticleModel article,
    required String label,
    required CategoryModel category,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.updateArticle(
          id: id,
          article: article,
          label: label,
          category: category,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>> migrateArticles() async {
    try {
      return Right(await articleRemoteDatasource.migrateArticles());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleListModel>>>
  migrateArticleToMultipleList() async {
    try {
      return Right(
        await articleRemoteDatasource.migrateArticleToMultipleList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
