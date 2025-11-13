import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

class ArticleImport implements UseCase<void, ArticleImportParams> {
  final ArticleRepository articleRepository;

  ArticleImport(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleListModel>>> call(
    ArticleImportParams params,
  ) async {
    return await articleRepository.articleImport(
      json: params.json,
      defaultCategory: params.defaultCategory,
    );
  }
}

class ArticleImportParams {
  final String json;
  final CategoryModel defaultCategory;

  ArticleImportParams({
    required this.json,
    required this.defaultCategory,
  });
}
