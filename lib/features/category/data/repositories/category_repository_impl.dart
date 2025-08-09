import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/features/category/data/datasources/category_remote_datasource.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource categoryRemoteDatasource;

  CategoryRepositoryImpl(this.categoryRemoteDatasource);

  @override
  Future<Either<Failure, List<CategoryModel>>> getAll() async {
    try {
      return Right(await categoryRemoteDatasource.getAll());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CategoryModel>>> addCategory({
    required CategoryModel category,
  }) async {
    try {
      return Right(
        await categoryRemoteDatasource.addCategory(category: category),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> removeCategory({
    required int index,
  }) async {
    try {
      return Right(await categoryRemoteDatasource.removeCategory(index: index));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> updateCategory({
    required CategoryModel category,
    required String label,
    required Color color,
  }) async {
    try {
      return Right(
        await categoryRemoteDatasource.updateCategory(
          category: category,
          label: label,
          color: color,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CategoryModel>>> categoryImport({
    required String json
  }) async {
    try {
      return Right(
        await categoryRemoteDatasource.categoryImport(
          json: json
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> clear() async {
    try {
      return Right(
        await categoryRemoteDatasource.clear(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> rerange({
    required int oldIndex,
    required int newIndex,
  }) async {
    try {
      return Right(
        await categoryRemoteDatasource.rerange(
          oldIndex: oldIndex,
          newIndex: newIndex,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
