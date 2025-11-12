import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

abstract interface class ArticleRepository {
  Future<Either<Failure, List<ArticleListModel>>> getAll();
  Future<Either<Failure, List<ArticleListModel>>> addArticle({
    required ArticleModel article,
  });
  Future<Either<Failure, List<ArticleListModel>>> removeArticle({
    required ArticleModel article,
  });
  Future<Either<Failure, List<ArticleListModel>>> toogleArticleDoneState({
    required ArticleModel article,
  });
  Future<Either<Failure, List<ArticleListModel>>> clear({required bool allArticle});
  Future<Either<Failure, List<ArticleListModel>>> articleImport({
    required String json,
    required CategoryModel defaultCategory,
  });
  Future<Either<Failure, List<ArticleListModel>>> updateArticle({
    required ArticleModel article,
    required String label,
    required CategoryModel category,
  });
  Future<Either<Failure, List<ArticleListModel>>> migrateArticles();
  Future<Either<Failure, List<ArticleListModel>>> migrateArticleToMultipleList();
}
