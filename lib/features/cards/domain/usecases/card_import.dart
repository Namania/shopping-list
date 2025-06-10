import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';

class CardImport implements UseCase<void, CardImportParams> {
  final CardRepository cardRepository;

  CardImport(this.cardRepository);

  @override
  Future<Either<Failure, List<CardModel>>> call(CardImportParams params) async {
    return await cardRepository.cardImport(json: params.json);
  }
}

class CardImportParams {
  final String json;

  CardImportParams({required this.json});
}
