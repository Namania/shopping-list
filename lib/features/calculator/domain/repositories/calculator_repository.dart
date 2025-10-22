import 'package:shopping_list/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CalculatorRepository {
  Future<Either<Failure, double>> getValue();
  Future<Either<Failure, double>> add({required double amount});
  Future<Either<Failure, double>> subtract({required double amount});
  Future<Either<Failure, double>> reset();
}
