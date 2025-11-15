import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../data/models/calculator_model.dart';
import '../repositories/calculator_repository.dart';

class CalculatorReset implements UseCase<void, CalculatorResetParams> {
  final CalculatorRepository calculatorRepository;

  CalculatorReset(this.calculatorRepository);

  @override
  Future<Either<Failure, List<CalculatorModel>>> call(CalculatorResetParams params) async {
    return await calculatorRepository.reset(idList: params.idList);
  }
}

class CalculatorResetParams {
  final String? idList;

  const CalculatorResetParams({this.idList});
}
