import 'package:fpdart/fpdart.dart';

import 'package:shopping_list/core/errors/failure.dart';

import '../../../article/data/models/article_model.dart';
import '../../domain/repositories/calculator_repository.dart';
import '../datasources/calculator_remote_datasource.dart';
import '../models/Calculator_model.dart';

class CalculatorRepositoryImpl implements CalculatorRepository {
  final CalculatorRemoteDatasource calculatorRemoteDatasource;

  CalculatorRepositoryImpl(this.calculatorRemoteDatasource);

  @override
  Future<Either<Failure, List<CalculatorModel>>> getAll() async {
    try {
      return Right(await calculatorRemoteDatasource.getAll());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CalculatorModel>>> add({required CalculatorModel value}) async {
    try {
      return Right(await calculatorRemoteDatasource.add(value: value));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CalculatorModel>>> subtract({required CalculatorModel value}) async {
    try {
      return Right(await calculatorRemoteDatasource.subtract(value: value));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CalculatorModel>>> reset({List<ArticleModel> articles = const []}) async {
    try {
      return Right(await calculatorRemoteDatasource.reset(articles: articles));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
