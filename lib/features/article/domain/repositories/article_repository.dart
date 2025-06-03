import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/entities/article.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ArticleRepository {
  Future<Either<Failure, List<Article>>> getAll();
  Future<Either<Failure, List<ArticleModel>>> addArticle({
    required ArticleModel article,
  });
  Future<Either<Failure, List<ArticleModel>>> removeArticle({
    required ArticleModel article,
  });
  Future<Either<Failure, List<ArticleModel>>> toogleArticleDoneState({
    required ArticleModel article,
  });
  Future<Either<Failure, List<Article>>> clear();
}