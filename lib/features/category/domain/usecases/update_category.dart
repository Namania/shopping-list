import 'package:flutter/material.dart';
import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/domain/repositories/category_repository.dart';

class UpdateCategory
    implements UseCase<List<CategoryModel>, UpdateCategoryParams> {
  final CategoryRepository categoryRepository;

  UpdateCategory(this.categoryRepository);

  @override
  Future<Either<Failure, List<CategoryModel>>> call(
    UpdateCategoryParams params,
  ) async {
    return await categoryRepository.updateCategory(
      category: params.category,
      label: params.label,
      color: params.color,
    );
  }
}

class UpdateCategoryParams {
  final CategoryModel category;
  final String label;
  final Color color;

  UpdateCategoryParams({
    required this.category,
    required this.label,
    required this.color,
  });
}
