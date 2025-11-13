import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddList implements UseCase<List<ArticleListModel>, AddListParams> {
  final ArticleRepository articleRepository;

  AddList(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleListModel>>> call(AddListParams params) async {
    return await articleRepository.addList(articleList: params.articleList);
  }
}

class AddListParams {
  final ArticleListModel articleList;

  AddListParams({required this.articleList});
}
