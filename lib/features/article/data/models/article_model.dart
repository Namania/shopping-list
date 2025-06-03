import 'dart:convert';

import 'package:shopping_list/features/article/domain/entities/article.dart';

// ignore: must_be_immutable
class ArticleModel extends Article {
  bool done;

  ArticleModel({
    required super.label,
    required super.quantity,
    required this.done,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'quantity': quantity,
      'done': done,
    };
  }

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      label: map['label'] as String,
      quantity: map['quantity'] as int,
      done: map['done'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ArticleModel.fromJson(String source) =>
      ArticleModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
