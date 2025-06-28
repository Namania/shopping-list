import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

abstract interface class ArticleRepository {
  Future<Either<Failure, List<ArticleModel>>> getAll();
  Future<Either<Failure, List<ArticleModel>>> addArticle({
    required ArticleModel article,
  });
  Future<Either<Failure, List<ArticleModel>>> removeArticle({
    required int index,
  });
  Future<Either<Failure, List<ArticleModel>>> toogleArticleDoneState({
    required int index,
  });
  Future<Either<Failure, List<ArticleModel>>> clear({required bool allArticle});
  Future<Either<Failure, List<ArticleModel>>> articleImport({
    required String json,
    required CategoryModel defaultCategory,
  });
  Future<Either<Failure, List<ArticleModel>>> updateArticle({
    required ArticleModel article,
    required String label,
    required CategoryModel category,
  });
}
