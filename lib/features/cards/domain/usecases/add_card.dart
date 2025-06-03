import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';

class AddCard implements UseCase<List<CardModel>, AddCardParams> {
  final CardRepository cardRepository;

  AddCard(this.cardRepository);

  @override
  Future<Either<Failure, List<CardModel>>> call(AddCardParams params) async {
    return await cardRepository.addCard(card: params.card);
  }
}

class AddCardParams {
  final CardModel card;

  AddCardParams({required this.card});
}
