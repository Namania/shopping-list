import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/article_model.dart';

abstract interface class ArticleRemoteDatasource {
  Future<List<ArticleModel>> getAll();
  Future<List<ArticleModel>> addArticle({
    required ArticleModel article,
  });
  Future<List<ArticleModel>> removeArticle({
    required ArticleModel article,
  });
  Future<List<ArticleModel>> toogleArticleDoneState({
    required ArticleModel article,
  });
  Future<List<ArticleModel>> clear({
    required bool allArticle
  });
}

class ArticleRemoteDatasourceImpl implements ArticleRemoteDatasource {
  final SharedPreferences prefs;

  ArticleRemoteDatasourceImpl(this.prefs);

  @override
  Future<List<ArticleModel>> getAll() async {
    bool hasKey = prefs.containsKey("articles");
    String? response = prefs.getString("articles");

    List<ArticleModel> data = [];
    if (hasKey && response != null) {
      List<dynamic> articles = jsonDecode(response);
      data = articles.map((article) => ArticleModel.fromJson(article)).toList();
    }

    return data;
  }

  @override
  Future<List<ArticleModel>> addArticle({
    required ArticleModel article,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      articles.add(article);
      await prefs.setString("articles", jsonEncode(articles.map((a) => a.toJson()).toList()));
      return await getAll();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ArticleModel>> removeArticle({
    required ArticleModel article,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      articles.removeWhere((a) => a.label == article.label && a.quantity == article.quantity && a.done == article.done);
      await prefs.setString("articles", jsonEncode(articles.map((a) => a.toJson()).toList()));
      return await getAll();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<ArticleModel>> toogleArticleDoneState({
    required ArticleModel article,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      ArticleModel a = articles.singleWhere((a) => a.label == article.label && a.quantity == article.quantity);
      a.done = !a.done;
      await prefs.setString("articles", jsonEncode(articles.map((a) => a.toJson()).toList()));
      return await getAll();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<ArticleModel>> clear({
    required bool allArticle
  }) async {
    try {
      if (allArticle) {
        await prefs.setString("articles", "[]");
      } else {
        List<ArticleModel> articles = await getAll();
        articles.removeWhere((a) => a.done);
        await prefs.setString("articles", jsonEncode(articles.map((a) => a.toJson()).toList()));
      }
      return await getAll();
    } catch (e) {
      return [];
    }
  }

}
