import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

class UpdateArticle
    implements UseCase<List<ArticleListModel>, UpdateArticleParams> {
  final ArticleRepository articleRepository;

  UpdateArticle(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleListModel>>> call(
    UpdateArticleParams params,
  ) async {
    return await articleRepository.updateArticle(
      id: params.id,
      article: params.article,
      label: params.label,
      category: params.category,
    );
  }
}

class UpdateArticleParams {
  final String id;
  final ArticleModel article;
  final String label;
  final CategoryModel category;

  UpdateArticleParams({
    required this.id,
    required this.article,
    required this.label,
    required this.category,
  });
}
