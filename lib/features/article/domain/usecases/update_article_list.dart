import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateList
    implements UseCase<List<ArticleListModel>, UpdateListParams> {
  final ArticleRepository articleRepository;

  UpdateList(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleListModel>>> call(
    UpdateListParams params,
  ) async {
    return await articleRepository.updateArticleList(
      articleList: params.articleList,
      label: params.label,
      card: params.card,
    );
  }
}

class UpdateListParams {
  final ArticleListModel articleList;
  final String label;
  final String card;

  UpdateListParams({
    required this.articleList,
    required this.label,
    required this.card,
  });
}
