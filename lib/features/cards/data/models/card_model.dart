import 'dart:convert';

import 'package:flutter/material.dart' as m;
import 'package:shopping_list/features/cards/domain/entities/card.dart';

class CardModel extends Card {
  const CardModel({
    required super.id,
    required super.label,
    required super.code,
    required super.color,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'code': code,
      'color': color.toARGB32(),
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: (map.containsKey('id') ? map['id'] : "") as String,
      label: map['label'] as String,
      code: map['code'] as String,
      color:
          map.containsKey('color')
              ? m.Color(map['color'])
              : m.Colors.transparent,
    );
  }

  String toJson() => json.encode(toMap());

  factory CardModel.fromJson(String source) =>
      CardModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
