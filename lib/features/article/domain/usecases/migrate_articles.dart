import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../data/models/article_model.dart';

class MigrateArticles implements UseCase<List<ArticleModel>, NoParams> {
  final ArticleRepository articleRepository;

  MigrateArticles(this.articleRepository);

  @override
  Future<Either<Failure, List<ArticleModel>>> call(NoParams params) async {
    return await articleRepository.migrateArticles();
  }
}
