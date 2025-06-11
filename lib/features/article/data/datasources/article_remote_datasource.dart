import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/article_model.dart';

abstract interface class ArticleRemoteDatasource {
  Future<List<ArticleModel>> getAll();
  Future<List<ArticleModel>> addArticle({
    required ArticleModel article,
  });
  Future<List<ArticleModel>> removeArticle({
    required int index,
  });
  Future<List<ArticleModel>> toogleArticleDoneState({
    required int index,
  });
  Future<List<ArticleModel>> clear({
    required bool allArticle
  });
  Future<List<ArticleModel>> articleImport({
    required String json
  });
  Future<List<ArticleModel>> updateArticle({
    required ArticleModel article,
    required String label,
    required int quantity,
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
      return await getAll();
    }
  }

  @override
  Future<List<ArticleModel>> removeArticle({
    required int index,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      articles.removeAt(index);
      await prefs.setString("articles", jsonEncode(articles.map((a) => a.toJson()).toList()));
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }
  
  @override
  Future<List<ArticleModel>> toogleArticleDoneState({
    required int index,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      ArticleModel article = articles[index];
      article.done = !article.done;
      await prefs.setString("articles", jsonEncode(articles.map((a) => a.toJson()).toList()));
      return await getAll();
    } catch (e) {
      return await getAll();
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
  
  @override
  Future<List<ArticleModel>> articleImport({
    required String json
  }) async {
    try {
      List<ArticleModel> articles = await getAll();

      List<dynamic> data = jsonDecode(json);
      for (Map<String, dynamic> element in data) {
        ArticleModel article = ArticleModel.fromMap(element);
        if (!articles.contains(article)) {
          await addArticle(article: article);
        }
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleModel>> updateArticle({
    required ArticleModel article,
    required String label,
    required int quantity,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      int index = articles.indexOf(article);
      articles.removeAt(index);
      ArticleModel updatedArticle = ArticleModel(
        label: label,
        quantity: quantity,
        done: article.done
      );
      articles.insert(index, updatedArticle);
      await prefs.setString("articles", jsonEncode(articles.map((a) => a.toJson()).toList()));
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

}
