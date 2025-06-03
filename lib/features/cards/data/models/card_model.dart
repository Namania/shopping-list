import 'dart:convert';

import 'package:shopping_list/features/cards/domain/entities/card.dart';

class CardModel extends Card {

  const CardModel({
    required super.label,
    required super.code,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'code': code,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      label: map['label'] as String,
      code: map['code'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CardModel.fromJson(String source) =>
      CardModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
