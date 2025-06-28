import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/domain/repositories/category_repository.dart';

class AddCategory implements UseCase<List<CategoryModel>, AddCategoryParams> {
  final CategoryRepository categoryRepository;

  AddCategory(this.categoryRepository);

  @override
  Future<Either<Failure, List<CategoryModel>>> call(AddCategoryParams params) async {
    return await categoryRepository.addCategory(category: params.category);
  }
}

class AddCategoryParams {
  final CategoryModel category;

  AddCategoryParams({required this.category});
}
