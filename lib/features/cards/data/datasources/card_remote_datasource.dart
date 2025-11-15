import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:uuid/uuid.dart';

abstract interface class CardRemoteDatasource {
  Future<List<CardModel>> cardGetAll();
  Future<List<CardModel>> addCard({required CardModel card});
  Future<List<CardModel>> removeCard({required CardModel card});
  Future<List<CardModel>> cardImport({required String json});
  Future<List<CardModel>> updateCard({
    required CardModel card,
    required String label,
    required String code,
    required Color color,
  });
  Future<List<CardModel>> rerange({
    required int oldIndex,
    required int newIndex,
  });
  Future<List<CardModel>> migrateCardAddId();
}

class CardRemoteDatasourceImpl implements CardRemoteDatasource {
  final SharedPreferences prefs;

  CardRemoteDatasourceImpl(this.prefs);

  @override
  Future<List<CardModel>> cardGetAll() async {
    bool hasKey = prefs.containsKey("cards");
    String? response = prefs.getString("cards");

    List<CardModel> data = [];
    if (hasKey && response != null) {
      List<dynamic> cards = jsonDecode(response);
      data = cards.map((card) => CardModel.fromJson(card)).toList();
    }

    return data;
  }

  @override
  Future<List<CardModel>> addCard({required CardModel card}) async {
    try {
      List<CardModel> cards = await cardGetAll();
      if (!cards.contains(card)) {
        cards.add(card);
        await prefs.setString(
          "cards",
          jsonEncode(cards.map((c) => c.toJson()).toList()),
        );
      }
      return await cardGetAll();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CardModel>> removeCard({required CardModel card}) async {
    try {
      List<CardModel> cards = await cardGetAll();
      cards.removeWhere(
        (c) =>
            c.label == card.label &&
            c.code == card.code &&
            c.color == card.color,
      );
      await prefs.setString(
        "cards",
        jsonEncode(cards.map((c) => c.toJson()).toList()),
      );
      return await cardGetAll();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CardModel>> cardImport({required String json}) async {
    try {
      List<CardModel> cards = await cardGetAll();

      List<dynamic> data = jsonDecode(json);
      for (Map<String, dynamic> element in data) {
        CardModel card = CardModel.fromMap(element);
        if (!cards.contains(card)) {
          await addCard(card: card);
        }
      }
      return await cardGetAll();
    } catch (e) {
      return await cardGetAll();
    }
  }

  @override
  Future<List<CardModel>> updateCard({
    required CardModel card,
    required String label,
    required String code,
    required Color color,
  }) async {
    try {
      List<CardModel> cards = await cardGetAll();
      int index = cards.indexOf(card);
      cards.removeAt(index);
      CardModel updatedCard = CardModel(
        id: card.id,
        label: label,
        code: code,
        color: color,
      );
      cards.insert(index, updatedCard);
      await prefs.setString(
        "cards",
        jsonEncode(cards.map((c) => c.toJson()).toList()),
      );
      return await cardGetAll();
    } catch (e) {
      return await cardGetAll();
    }
  }

  @override
  Future<List<CardModel>> rerange({
    required int oldIndex,
    required int newIndex,
  }) async {
    try {
      List<CardModel> cards = await cardGetAll();
      final item = cards.removeAt(oldIndex);
      cards.insert(newIndex, item);
      await prefs.setString(
        "cards",
        jsonEncode(cards.map((c) => c.toJson()).toList()),
      );
      return await cardGetAll();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CardModel>> migrateCardAddId() async {
    try {
      Uuid uuid = Uuid();
      bool hasKey = prefs.containsKey("cards");
      String? response = prefs.getString("cards");

      if (hasKey && response != null) {
        List<CardModel> cards = [];
        List<dynamic> data = jsonDecode(response);
        cards = data.map((card) => CardModel.fromJson(card)).toList();

        List<CardModel> migratedArticles = [];
        for (CardModel card in cards) {
          if (card.id == "") {
            CardModel newA = CardModel(
              id: uuid.v4(),
              label: card.label,
              code: card.code,
              color: card.color,
            );
            migratedArticles.add(newA);
          } else {
            migratedArticles.add(card);
          }
        }

        await prefs.setString(
          "cards",
          jsonEncode(migratedArticles.map((a) => a.toJson()).toList()),
        );
      }
      return await cardGetAll();
    } catch (e) {
      return await cardGetAll();
    }
  }
}
