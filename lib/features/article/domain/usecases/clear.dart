import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/domain/entities/article.dart';
import 'package:shopping_list/features/article/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class Clear implements UseCase<void, NoParams> {
  final ArticleRepository articleRepository;

  Clear(this.articleRepository);

  @override
  Future<Either<Failure, List<Article>>> call(NoParams params) async {
    return await articleRepository.clear();
  }
}
