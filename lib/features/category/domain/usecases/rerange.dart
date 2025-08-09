import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/domain/repositories/category_repository.dart';

class RerangeCategory implements UseCase<List<CategoryModel>, RerangeCategoryParams> {
  final CategoryRepository categoryRepository;

  RerangeCategory(this.categoryRepository);

  @override
  Future<Either<Failure, List<CategoryModel>>> call(RerangeCategoryParams params) async {
    return await categoryRepository.rerange(oldIndex: params.oldIndex, newIndex: params.newIndex);
  }
}

class RerangeCategoryParams {
  final int oldIndex;
  final int newIndex;

  RerangeCategoryParams({
    required this.oldIndex,
    required this.newIndex,
  });
}
