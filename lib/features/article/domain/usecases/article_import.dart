import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class ArticleImport implements UseCase<void, ArticleImportParams> {
  final ArticleRepository articleRepository;

  ArticleImport(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleModel>>> call(
    ArticleImportParams params,
  ) async {
    return await articleRepository.articleImport(json: params.json);
  }
}

class ArticleImportParams {
  final String json;

  ArticleImportParams({required this.json});
}
