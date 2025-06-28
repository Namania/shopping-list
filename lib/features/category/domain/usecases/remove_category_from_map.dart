import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/domain/repositories/category_repository.dart';

class RemoveCategory
    implements UseCase<List<CategoryModel>, RemoveCategoryParams> {
  final CategoryRepository categoryRepository;

  RemoveCategory(this.categoryRepository);

  @override
  Future<Either<Failure, List<CategoryModel>>> call(
    RemoveCategoryParams params,
  ) async {
    return await categoryRepository.removeCategory(index: params.index);
  }
}

class RemoveCategoryParams {
  final int index;

  RemoveCategoryParams({required this.index});
}
