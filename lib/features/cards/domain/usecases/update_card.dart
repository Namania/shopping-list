import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';

class UpdateCard implements UseCase<List<CardModel>, UpdateCardParams> {
  final CardRepository cardRepository;

  UpdateCard(this.cardRepository);

  @override
  Future<Either<Failure, List<CardModel>>> call(UpdateCardParams params) async {
    return await cardRepository.updateCard(
      card: params.card,
      label: params.label,
      code: params.code,
    );
  }
}

class UpdateCardParams {
  final CardModel card;
  final String label;
  final String code;

  UpdateCardParams({
    required this.card,
    required this.label,
    required this.code,
  });
}
