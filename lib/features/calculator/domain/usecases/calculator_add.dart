import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/calculator/domain/repositories/calculator_repository.dart';

class CalculatorAdd implements UseCase<double, CalculatorAddParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorAdd(this.calculatorRepository);

  @override
  Future<Either<Failure, double>> call(CalculatorAddParams params) async {
    return await calculatorRepository.add(amount: params.amount);
  }
}

class CalculatorAddParams {
  final double amount;

  CalculatorAddParams({required this.amount});
}
