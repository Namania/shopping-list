import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class ToogleArticleDoneState implements UseCase<List<ArticleListModel>, ToogleArticleDoneStateParams> {
  final ArticleRepository articleRepository;

  ToogleArticleDoneState(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleListModel>>> call(ToogleArticleDoneStateParams params) async {
    return await articleRepository.toogleArticleDoneState(article: params.article);
  }
}

class ToogleArticleDoneStateParams {
  final ArticleModel article;

  ToogleArticleDoneStateParams({required this.article});
}
