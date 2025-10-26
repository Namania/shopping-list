import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/calculator/domain/repositories/calculator_repository.dart';

import '../../data/models/Calculator_model.dart';

class CalculatorSubtractWithoutArticle implements UseCase<List<CalculatorModel>, CalculatorSubtractWithoutArticleParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorSubtractWithoutArticle(this.calculatorRepository);

  @override
  Future<Either<Failure, List<CalculatorModel>>> call(CalculatorSubtractWithoutArticleParams params) async {
    return await calculatorRepository.subtractWithoutArticle(value: params.value);
  }
}

class CalculatorSubtractWithoutArticleParams {
  final CalculatorModel value;

  CalculatorSubtractWithoutArticleParams({required this.value});
}
