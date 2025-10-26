import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/calculator/data/models/Calculator_model.dart';
import 'package:shopping_list/features/calculator/domain/repositories/calculator_repository.dart';

class CalculatorAddWithoutArticle implements UseCase<List<CalculatorModel>, CalculatorAddWithoutArticleParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorAddWithoutArticle(this.calculatorRepository);

  @override
  Future<Either<Failure, List<CalculatorModel>>> call(CalculatorAddWithoutArticleParams params) async {
    return await calculatorRepository.addWithoutArticle(price: params.price);
  }
}

class CalculatorAddWithoutArticleParams {
  final double price;

  CalculatorAddWithoutArticleParams({required this.price});
}
