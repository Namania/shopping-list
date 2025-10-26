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
  Future<Either<Failure, List<CalculatorModel>>> getAllWithArticle() async {
    try {
      return Right(await calculatorRemoteDatasource.getAllWithArticle());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CalculatorModel>>> getAllWithoutArticle() async {
    try {
      return Right(await calculatorRemoteDatasource.getAllWithoutArticle());
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
  Future<Either<Failure, List<CalculatorModel>>> addWithoutArticle({required double price}) async {
    try {
      return Right(await calculatorRemoteDatasource.addWithoutArticle(price: price));
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
  Future<Either<Failure, List<CalculatorModel>>> subtractWithoutArticle({required CalculatorModel value}) async {
    try {
      return Right(await calculatorRemoteDatasource.subtractWithoutArticle(value: value));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CalculatorModel>>> reset() async {
    try {
      return Right(await calculatorRemoteDatasource.reset());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CalculatorModel>>> resetWith({List<ArticleModel> articles = const []}) async {
    try {
      return Right(await calculatorRemoteDatasource.resetWith(articles: articles));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CalculatorModel>>> resetWithoutArticle({List<String> articles = const []}) async {
    try {
      return Right(await calculatorRemoteDatasource.resetWithoutArticle(articles: articles));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
