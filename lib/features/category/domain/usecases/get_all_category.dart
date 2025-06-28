import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/domain/repositories/category_repository.dart';

class GetAllCategory implements UseCase<void, NoParams> {
  final CategoryRepository categoryRepository;

  GetAllCategory(this.categoryRepository);

  @override
  Future<Either<Failure, List<CategoryModel>>> call(NoParams params) async {
    return await categoryRepository.getAll();
  }
}
