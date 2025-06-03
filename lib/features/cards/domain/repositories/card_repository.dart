import 'package:shopping_list/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';

abstract interface class CardRepository {
  Future<Either<Failure, List<CardModel>>> cardGetAll();
  Future<Either<Failure, List<CardModel>>> addCard({
    required CardModel card,
  });
  Future<Either<Failure, List<CardModel>>> removeCard({
    required CardModel card,
  });
}