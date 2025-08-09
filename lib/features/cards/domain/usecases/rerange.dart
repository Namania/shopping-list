import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';

class RerangeCard implements UseCase<List<CardModel>, RerangeCardParams> {
  final CardRepository cardRepository;

  RerangeCard(this.cardRepository);

  @override
  Future<Either<Failure, List<CardModel>>> call(RerangeCardParams params) async {
    return await cardRepository.rerange(oldIndex: params.oldIndex, newIndex: params.newIndex);
  }
}

class RerangeCardParams {
  final int oldIndex;
  final int newIndex;

  RerangeCardParams({
    required this.oldIndex,
    required this.newIndex,
  });
}
