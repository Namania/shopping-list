import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveList implements UseCase<List<ArticleListModel>, RemoveListParams> {
  final ArticleRepository articleRepository;

  RemoveList(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleListModel>>> call(RemoveListParams params) async {
    return await articleRepository.removeList(articleList: params.articleList);
  }
}

class RemoveListParams {
  final ArticleListModel articleList;

  RemoveListParams({required this.articleList});
}
