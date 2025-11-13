import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class Clear implements UseCase<void, ClearParams> {
  final ArticleRepository articleRepository;

  Clear(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleListModel>>> call(
    ClearParams params,
  ) async {
    return await articleRepository.clear(
      id: params.id,
      allArticle: params.allArticle,
    );
  }
}

class ClearParams {
  final String id;
  final bool allArticle;

  ClearParams({required this.id, required this.allArticle});
}
