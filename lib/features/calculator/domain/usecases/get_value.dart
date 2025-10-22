import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../repositories/calculator_repository.dart';

class GetValue implements UseCase<void, NoParams> {
  final CalculatorRepository calculatorRepository;

  GetValue(this.calculatorRepository);

  @override
  Future<Either<Failure, double>> call(NoParams params) async {
    return await calculatorRepository.getValue();
  }
}
