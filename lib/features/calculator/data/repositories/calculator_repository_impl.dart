import 'package:fpdart/fpdart.dart';

import 'package:shopping_list/core/errors/failure.dart';

import '../../../article/data/models/article_model.dart';
import '../../domain/repositories/calculator_repository.dart';
import '../datasources/calculator_remote_datasource.dart';
import '../models/calculator_model.dart';

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
  Future<Either<Failure, List<CalculatorModel>>> addWithoutArticle({required String idList, required double price}) async {
    try {
      return Right(await calculatorRemoteDatasource.addWithoutArticle(idList: idList, price: price));
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
  Future<Either<Failure, List<CalculatorModel>>> reset({String? idList}) async {
    try {
      return Right(await calculatorRemoteDatasource.reset(idList: idList));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CalculatorModel>>> resetWith({String? idList, List<ArticleModel> articles = const []}) async {
    try {
      return Right(await calculatorRemoteDatasource.resetWith(idList: idList, articles: articles));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CalculatorModel>>> resetWithoutArticle({String? idList, List<String> articles = const []}) async {
    try {
      return Right(await calculatorRemoteDatasource.resetWithoutArticle(idList: idList, articles: articles));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
