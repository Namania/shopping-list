import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/calculator/data/models/calculator_model.dart';
import 'package:shopping_list/features/calculator/domain/repositories/calculator_repository.dart';

class CalculatorAdd implements UseCase<List<CalculatorModel>, CalculatorAddParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorAdd(this.calculatorRepository);

  @override
  Future<Either<Failure, List<CalculatorModel>>> call(CalculatorAddParams params) async {
    return await calculatorRepository.add(value: params.value);
  }
}

class CalculatorAddParams {
  final CalculatorModel value;

  CalculatorAddParams({required this.value});
}
