import 'package:flutter/material.dart';
import 'package:shopping_list/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';

abstract interface class CardRepository {
  Future<Either<Failure, List<CardModel>>> cardGetAll();
  Future<Either<Failure, List<CardModel>>> addCard({required CardModel card});
  Future<Either<Failure, List<CardModel>>> removeCard({
    required CardModel card,
  });
  Future<Either<Failure, List<CardModel>>> cardImport({required String json});
  Future<Either<Failure, List<CardModel>>> updateCard({
    required CardModel card,
    required String label,
    required String code,
    required Color color,
  });
  Future<Either<Failure, List<CardModel>>> rerange({
    required int oldIndex,
    required int newIndex,
  });
  Future<Either<Failure, List<CardModel>>> migrateCardAddId();
}
