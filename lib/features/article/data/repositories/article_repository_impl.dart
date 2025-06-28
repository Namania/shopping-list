import 'package:shopping_list/features/article/data/datasources/article_remote_datasource.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDatasource articleRemoteDatasource;

  ArticleRepositoryImpl(this.articleRemoteDatasource);

  @override
  Future<Either<Failure, List<ArticleModel>>> getAll() async {
    try {
      return Right(
        await articleRemoteDatasource.getAll(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ArticleModel>>> addArticle({
    required ArticleModel article,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.addArticle(article: article),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ArticleModel>>> removeArticle({
    required int index,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.removeArticle(index: index),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ArticleModel>>> toogleArticleDoneState({
    required int index,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.toogleArticleDoneState(index: index),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleModel>>> clear({
    required bool allArticle
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.clear(
          allArticle: allArticle
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ArticleModel>>> articleImport({
    required String json
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.articleImport(
          json: json
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ArticleModel>>> updateArticle({
    required ArticleModel article,
    required String label,
    required CategoryModel category,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.updateArticle(
          article: article,
          label: label,
          category: category,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

}
