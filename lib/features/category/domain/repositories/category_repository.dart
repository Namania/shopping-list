import 'package:flutter/material.dart';
import 'package:shopping_list/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

abstract interface class CategoryRepository {
  Future<Either<Failure, List<CategoryModel>>> getAll();
  Future<Either<Failure, List<CategoryModel>>> addCategory({
    required CategoryModel category,
  });
  Future<Either<Failure, List<CategoryModel>>> removeCategory({
    required int index,
  });
  Future<Either<Failure, List<CategoryModel>>> updateCategory({
    required CategoryModel category,
    required String label,
    required Color color,
  });
  Future<Either<Failure, List<CategoryModel>>> categoryImport({required String json});
  Future<Either<Failure, List<CategoryModel>>> clear();
}
