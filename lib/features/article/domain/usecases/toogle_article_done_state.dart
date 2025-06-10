import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class ToogleArticleDoneState implements UseCase<List<ArticleModel>, ToogleArticleDoneStateParams> {
  final ArticleRepository articleRepository;

  ToogleArticleDoneState(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleModel>>> call(ToogleArticleDoneStateParams params) async {
    return await articleRepository.toogleArticleDoneState(index: params.index);
  }
}

class ToogleArticleDoneStateParams {
  final int index;

  ToogleArticleDoneStateParams({required this.index});
}
