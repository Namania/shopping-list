import 'package:shopping_list/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../data/models/Calculator_model.dart';

abstract interface class CalculatorRepository {
  Future<Either<Failure, List<CalculatorModel>>> getAll();
  Future<Either<Failure, List<CalculatorModel>>> add({required CalculatorModel value});
  Future<Either<Failure, List<CalculatorModel>>> subtract({required CalculatorModel value});
  Future<Either<Failure, List<CalculatorModel>>> reset();
}
