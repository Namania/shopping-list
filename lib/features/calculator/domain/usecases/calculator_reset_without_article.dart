import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../data/models/calculator_model.dart';
import '../repositories/calculator_repository.dart';

class CalculatorResetWithoutArticle implements UseCase<void, CalculatorResetWithoutArticleParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorResetWithoutArticle(this.calculatorRepository);

  @override
  Future<Either<Failure, List<CalculatorModel>>> call(CalculatorResetWithoutArticleParams params) async {
    return await calculatorRepository.resetWithoutArticle(idList: params.idList, articles: params.articles);
  }
}

class CalculatorResetWithoutArticleParams {
  final String? idList;
  final List<String> articles;

  const CalculatorResetWithoutArticleParams({this.idList, this.articles = const []});
}
