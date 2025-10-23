import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

import '../models/article_model.dart';

abstract interface class ArticleRemoteDatasource {
  Future<List<ArticleModel>> getAll();
  Future<List<CategoryModel>> getAllCategories();
  Future<List<ArticleModel>> addArticle({required ArticleModel article});
  Future<List<ArticleModel>> removeArticle({required ArticleModel article});
  Future<List<ArticleModel>> toogleArticleDoneState({
    required ArticleModel article,
  });
  Future<List<ArticleModel>> clear({required bool allArticle});
  Future<List<ArticleModel>> articleImport({
    required String json,
    required CategoryModel defaultCategory,
  });
  Future<List<ArticleModel>> updateArticle({
    required ArticleModel article,
    required String label,
    required CategoryModel category,
  });
  Future<List<ArticleModel>> migrateArticles();
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
  Future<List<CategoryModel>> getAllCategories() async {
    bool hasKey = prefs.containsKey("categories");
    String? response = prefs.getString("categories");

    List<CategoryModel> data = [];
    if (hasKey && response != null) {
      List<dynamic> categories = jsonDecode(response);
      data =
          categories
              .map((category) => CategoryModel.fromJson(category))
              .toList();
    }

    return data;
  }

  @override
  Future<List<ArticleModel>> addArticle({required ArticleModel article}) async {
    try {
      List<ArticleModel> articles = await getAll();
      List<ArticleModel> exist =
          articles.where((a) => a.label == article.label).toList();
      if (exist.isEmpty) {
        articles.add(article);
        await prefs.setString(
          "articles",
          jsonEncode(articles.map((a) => a.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleModel>> removeArticle({
    required ArticleModel article,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      articles.remove(article);
      await prefs.setString(
        "articles",
        jsonEncode(articles.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleModel>> toogleArticleDoneState({
    required ArticleModel article,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      int index = articles.indexOf(article);
      articles[index].done = !articles[index].done;
      await prefs.setString(
        "articles",
        jsonEncode(articles.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleModel>> clear({required bool allArticle}) async {
    try {
      if (allArticle) {
        await prefs.setString("articles", "[]");
      } else {
        List<ArticleModel> articles = await getAll();
        articles.removeWhere((a) => a.done);
        await prefs.setString(
          "articles",
          jsonEncode(articles.map((a) => a.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ArticleModel>> articleImport({
    required String json,
    required CategoryModel defaultCategory,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      List<CategoryModel> categories = await getAllCategories();

      List<dynamic> data = jsonDecode(json);
      for (Map<String, dynamic> element in data) {
        ArticleModel article = ArticleModel.fromMap(element);
        if (!categories.contains(article.category)) {
          article.category = defaultCategory;
        }
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
    required CategoryModel category,
  }) async {
    try {
      List<ArticleModel> articles = await getAll();
      int index = articles.indexOf(article);
      articles.removeAt(index);
      ArticleModel updatedArticle = ArticleModel(
        id: article.id,
        label: label,
        category: category,
        done: article.done,
      );
      articles.insert(index, updatedArticle);
      articles.sort(
        (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
      articles.sort(
        (a, b) => a.category.label.toLowerCase().compareTo(
          b.category.label.toLowerCase(),
        ),
      );
      await prefs.setString(
        "articles",
        jsonEncode(articles.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleModel>> migrateArticles() async {
    try {
      Uuid uuid = Uuid();
      List<ArticleModel> articles = await getAll();
      List<ArticleModel> migratedArticles = [];
      for (ArticleModel article in articles) {
        if (article.id == "") {
          ArticleModel newA = ArticleModel(
            id: uuid.v4(),
            label: article.label,
            category: article.category,
            done: article.done
          );
          migratedArticles.add(newA);
        } else {
          migratedArticles.add(article);
        }
      }

      if (articles.length == migratedArticles.length) {
        await prefs.setString(
          "articles",
          jsonEncode(migratedArticles.map((a) => a.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }
}
