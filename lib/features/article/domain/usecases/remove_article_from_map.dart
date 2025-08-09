import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveArticle implements UseCase<List<ArticleModel>, RemoveArticleParams> {
  final ArticleRepository articleRepository;

  RemoveArticle(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleModel>>> call(RemoveArticleParams params) async {
    return await articleRepository.removeArticle(article: params.article);
  }
}

class RemoveArticleParams {
  final ArticleModel article;

  RemoveArticleParams({required this.article});
}
