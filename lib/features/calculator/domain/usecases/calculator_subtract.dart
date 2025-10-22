import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/calculator/domain/repositories/calculator_repository.dart';

class CalculatorSubtract implements UseCase<double, CalculatorSubtractParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorSubtract(this.calculatorRepository);

  @override
  Future<Either<Failure, double>> call(CalculatorSubtractParams params) async {
    return await calculatorRepository.subtract(amount: params.amount);
  }
}

class CalculatorSubtractParams {
  final double amount;

  CalculatorSubtractParams({required this.amount});
}
