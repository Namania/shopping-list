import 'dart:convert';

import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/entities/article_list.dart';

// ignore: must_be_immutable
class ArticleListModel extends ArticleList {

  ArticleListModel({
    required super.id,
    required super.label,
    required super.articles,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'articles': articles.map((a) => a.toMap()).toList(),
    };
  }

  factory ArticleListModel.fromMap(Map<String, dynamic> map) {
    return ArticleListModel(
      id: (map.containsKey('id') ? map['id'] : "") as String,
      label: map['label'] as String,
      articles: (map['articles'] as List<dynamic>).map((a) => ArticleModel.fromMap(a)).toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ArticleListModel.fromJson(String source) =>
      ArticleListModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
