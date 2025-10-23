import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../../article/data/models/article_model.dart';
import '../../data/models/Calculator_model.dart';
import '../repositories/calculator_repository.dart';

class CalculatorReset implements UseCase<void, CalculatorResetParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorReset(this.calculatorRepository);

  @override
  Future<Either<Failure, List<CalculatorModel>>> call(CalculatorResetParams params) async {
    return await calculatorRepository.reset(articles: params.articles);
  }
}

class CalculatorResetParams {
  final List<ArticleModel> articles;

  const CalculatorResetParams({this.articles = const []});
}
