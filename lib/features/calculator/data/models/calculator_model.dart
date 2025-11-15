import 'dart:convert';

import '../../domain/entities/calculator.dart';

class CalculatorModel extends Calculator {

  const CalculatorModel({
    required super.idList,
    required super.idArticle,
    required super.price,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_list': idList,
      'id_article': idArticle,
      'price': price,
    };
  }

  factory CalculatorModel.fromMap(Map<String, dynamic> map) {
    return CalculatorModel(
      idList: (map.containsKey('id_list') ? map['id_list'] : "") as String,
      idArticle: map['id_article'] as String,
      price: map['price'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory CalculatorModel.fromJson(String source) =>
      CalculatorModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
