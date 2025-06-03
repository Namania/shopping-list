import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';

class CardGetAll implements UseCase<void, NoParams> {
  final CardRepository cardRepository;

  CardGetAll(this.cardRepository);

  @override
  Future<Either<Failure, List<CardModel>>> call(NoParams params) async {
    return await cardRepository.cardGetAll();
  }
}
