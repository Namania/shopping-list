import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';

class RerangeArticle implements UseCase<List<ArticleListModel>, RerangeArticleParams> {
  final ArticleRepository articleRepository;

  RerangeArticle(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleListModel>>> call(RerangeArticleParams params) async {
    return await articleRepository.rerange(oldIndex: params.oldIndex, newIndex: params.newIndex);
  }
}

class RerangeArticleParams {
  final int oldIndex;
  final int newIndex;

  RerangeArticleParams({
    required this.oldIndex,
    required this.newIndex,
  });
}
