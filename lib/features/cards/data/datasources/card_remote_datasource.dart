import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';

abstract interface class CardRemoteDatasource {
  Future<List<CardModel>> cardGetAll();
  Future<List<CardModel>> addCard({
    required CardModel card,
  });
  Future<List<CardModel>> removeCard({
    required CardModel card,
  });
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
  Future<List<CardModel>> addCard({
    required CardModel card,
  }) async {
    try {
      List<CardModel> cards = await cardGetAll();
      cards.add(card);
      await prefs.setString("cards", jsonEncode(cards.map((c) => c.toJson()).toList()));
      return await cardGetAll();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<CardModel>> removeCard({
    required CardModel card,
  }) async {
    try {
      List<CardModel> cards = await cardGetAll();
      cards.removeWhere((c) => c.label == card.label && c.code == card.code);
      await prefs.setString("cards", jsonEncode(cards.map((a) => a.toJson()).toList()));
      return await cardGetAll();
    } catch (e) {
      return [];
    }
  }

}
