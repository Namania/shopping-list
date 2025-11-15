import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

abstract interface class ArticleRepository {
  Future<Either<Failure, List<ArticleListModel>>> getAll();
  Future<Either<Failure, List<ArticleListModel>>> addArticle({
    required String id,
    required ArticleModel article,
  });
  Future<Either<Failure, List<ArticleListModel>>> addList({
    required ArticleListModel articleList,
  });
  Future<Either<Failure, List<ArticleListModel>>> removeArticle({
    required String id,
    required ArticleModel article,
  });
  Future<Either<Failure, List<ArticleListModel>>> removeList({
    required ArticleListModel articleList,
  });
  Future<Either<Failure, List<ArticleListModel>>> toogleArticleDoneState({
    required String id,
    required ArticleModel article,
  });
  Future<Either<Failure, List<ArticleListModel>>> clear({
    required String id,
    required bool allArticle,
  });
  Future<Either<Failure, List<ArticleListModel>>> articleImport({
    required String json,
    required CategoryModel defaultCategory,
  });
  Future<Either<Failure, List<ArticleListModel>>> updateArticle({
    required String id,
    required ArticleModel article,
    required String label,
    required CategoryModel category,
  });
  Future<Either<Failure, List<ArticleListModel>>> updateArticleList({
    required ArticleListModel articleList,
    required String label,
    required String card,
  });
  Future<Either<Failure, List<ArticleListModel>>> rerange({
    required int oldIndex,
    required int newIndex,
  });
  Future<Either<Failure, List<ArticleListModel>>> migrateArticleToMultipleList();
}
