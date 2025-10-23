import 'dart:convert';

import 'package:shopping_list/features/article/domain/entities/article.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

// ignore: must_be_immutable
class ArticleModel extends Article {

  ArticleModel({
    required super.id,
    required super.label,
    required super.category,
    required super.done,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'category': category.toMap(),
      'done': done,
    };
  }

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: (map.containsKey('id') ? map['id'] : "") as String,
      label: map['label'] as String,
      category: CategoryModel.fromMap(map['category']),
      done: map['done'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ArticleModel.fromJson(String source) =>
      ArticleModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
