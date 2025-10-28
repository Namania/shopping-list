import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../data/models/calculator_model.dart';
import '../repositories/calculator_repository.dart';

class CalculatorGetAllWithArticle implements UseCase<void, NoParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorGetAllWithArticle(this.calculatorRepository);

  @override
  Future<Either<Failure, List<CalculatorModel>>> call(NoParams params) async {
    return await calculatorRepository.getAllWithArticle();
  }
}
