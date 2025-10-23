import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/calculator/domain/repositories/calculator_repository.dart';

import '../../data/models/Calculator_model.dart';

class CalculatorSubtract implements UseCase<List<CalculatorModel>, CalculatorSubtractParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorSubtract(this.calculatorRepository);

  @override
  Future<Either<Failure, List<CalculatorModel>>> call(CalculatorSubtractParams params) async {
    return await calculatorRepository.subtract(value: params.value);
  }
}

class CalculatorSubtractParams {
  final CalculatorModel value;

  CalculatorSubtractParams({required this.value});
}
