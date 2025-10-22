import 'package:fpdart/fpdart.dart';

import 'package:shopping_list/core/errors/failure.dart';

import '../../domain/repositories/calculator_repository.dart';
import '../datasources/calculator_remote_datasource.dart';

class CalculatorRepositoryImpl implements CalculatorRepository {
  final CalculatorRemoteDatasource calculatorRemoteDatasource;

  CalculatorRepositoryImpl(this.calculatorRemoteDatasource);

  @override
  Future<Either<Failure, double>> getValue() async {
    try {
      return Right(await calculatorRemoteDatasource.getValue());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> add({required double amount}) async {
    try {
      return Right(await calculatorRemoteDatasource.add(amount: amount));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, double>> subtract({required double amount}) async {
    try {
      return Right(await calculatorRemoteDatasource.subtract(amount: amount));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, double>> reset() async {
    try {
      return Right(await calculatorRemoteDatasource.reset());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
