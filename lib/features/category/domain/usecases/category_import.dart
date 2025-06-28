import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/domain/repositories/category_repository.dart';

class CategoryImport implements UseCase<void, CategoryImportParams> {
  final CategoryRepository categoryRepository;

  CategoryImport(this.categoryRepository);

  @override
  Future<Either<Failure, List<CategoryModel>>> call(
    CategoryImportParams params,
  ) async {
    return await categoryRepository.categoryImport(json: params.json);
  }
}

class CategoryImportParams {
  final String json;

  CategoryImportParams({required this.json});
}
