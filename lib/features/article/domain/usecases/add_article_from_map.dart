import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddArticle implements UseCase<List<ArticleListModel>, AddArticleParams> {
  final ArticleRepository articleRepository;

  AddArticle(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleListModel>>> call(AddArticleParams params) async {
    return await articleRepository.addArticle(id: params.id, article: params.article);
  }
}

class AddArticleParams {
  final String id;
  final ArticleModel article;

  AddArticleParams({required this.id, required this.article});
}
