import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';

class RemoveCard implements UseCase<List<CardModel>, RemoveCardParams> {
  final CardRepository cardRepository;

  RemoveCard(this.cardRepository);

  @override
  Future<Either<Failure, List<CardModel>>> call(RemoveCardParams params) async {
    return await cardRepository.removeCard(card: params.card);
  }
}

class RemoveCardParams {
  final CardModel card;

  RemoveCardParams({required this.card});
}
