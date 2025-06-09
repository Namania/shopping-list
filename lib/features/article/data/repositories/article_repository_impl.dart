import 'package:shopping_list/features/article/data/datasources/article_remote_datasource.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/entities/article.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

import 'package:shopping_list/core/errors/failure.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDatasource articleRemoteDatasource;

  ArticleRepositoryImpl(this.articleRemoteDatasource);

  @override
  Future<Either<Failure, List<Article>>> getAll() async {
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
    required ArticleModel article,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.removeArticle(article: article),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ArticleModel>>> toogleArticleDoneState({
    required ArticleModel article,
  }) async {
    try {
      return Right(
        await articleRemoteDatasource.toogleArticleDoneState(article: article),
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

}
