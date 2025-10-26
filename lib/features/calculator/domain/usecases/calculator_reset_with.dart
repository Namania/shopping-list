import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../../article/data/models/article_model.dart';
import '../../data/models/Calculator_model.dart';
import '../repositories/calculator_repository.dart';

class CalculatorResetWith implements UseCase<void, CalculatorResetWithParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorResetWith(this.calculatorRepository);

  @override
  Future<Either<Failure, List<CalculatorModel>>> call(CalculatorResetWithParams params) async {
    return await calculatorRepository.resetWith(articles: params.articles);
  }
}

class CalculatorResetWithParams {
  final List<ArticleModel> articles;

  const CalculatorResetWithParams({this.articles = const []});
}
