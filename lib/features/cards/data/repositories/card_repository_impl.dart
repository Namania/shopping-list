import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:shopping_list/core/errors/failure.dart';
import 'package:shopping_list/features/cards/data/datasources/card_remote_datasource.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/domain/repositories/card_repository.dart';

class CardRepositoryImpl implements CardRepository {
  final CardRemoteDatasource cardRemoteDatasource;

  CardRepositoryImpl(this.cardRemoteDatasource);

  @override
  Future<Either<Failure, List<CardModel>>> cardGetAll() async {
    try {
      return Right(await cardRemoteDatasource.cardGetAll());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CardModel>>> addCard({
    required CardModel card,
  }) async {
    try {
      return Right(await cardRemoteDatasource.addCard(card: card));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CardModel>>> removeCard({
    required CardModel card,
  }) async {
    try {
      return Right(await cardRemoteDatasource.removeCard(card: card));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CardModel>>> cardImport({
    required String json,
  }) async {
    try {
      return Right(await cardRemoteDatasource.cardImport(json: json));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CardModel>>> updateCard({
    required CardModel card,
    required String label,
    required String code,
    required Color color,
  }) async {
    try {
      return Right(
        await cardRemoteDatasource.updateCard(
          card: card,
          label: label,
          code: code,
          color: color,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CardModel>>> rerange({
    required int oldIndex,
    required int newIndex,
  }) async {
    try {
      return Right(
        await cardRemoteDatasource.rerange(
          oldIndex: oldIndex,
          newIndex: newIndex,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CardModel>>> migrateCardAddId() async {
    try {
      return Right(
        await cardRemoteDatasource.migrateCardAddId(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

}
