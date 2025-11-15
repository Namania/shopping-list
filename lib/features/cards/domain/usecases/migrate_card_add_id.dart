import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../data/models/card_model.dart';

class MigrateCardAddId implements UseCase<List<CardModel>, NoParams> {
  final CardRepository cardRepository;

  MigrateCardAddId(this.cardRepository);

  @override
  Future<Either<Failure, List<CardModel>>> call(NoParams params) async {
    return await cardRepository.migrateCardAddId();
  }
}
