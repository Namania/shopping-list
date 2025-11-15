import 'dart:convert';

import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

import '../models/article_model.dart';

abstract interface class ArticleRemoteDatasource {
  Future<List<ArticleListModel>> getAll();
  Future<List<CategoryModel>> getAllCategories();
  Future<List<ArticleListModel>> addArticle({
    required String id,
    required ArticleModel article,
  });
  Future<List<ArticleListModel>> addList({
    required ArticleListModel articleList,
  });
  Future<List<ArticleListModel>> removeArticle({
    required String id,
    required ArticleModel article,
  });
  Future<List<ArticleListModel>> removeList({
    required ArticleListModel articleList,
  });
  Future<List<ArticleListModel>> toogleArticleDoneState({
    required String id,
    required ArticleModel article,
  });
  Future<List<ArticleListModel>> clear({
    required String id,
    required bool allArticle,
  });
  Future<List<ArticleListModel>> articleImport({
    required String json,
    required CategoryModel defaultCategory,
  });
  Future<List<ArticleListModel>> updateArticle({
    required String id,
    required ArticleModel article,
    required String label,
    required CategoryModel category,
  });
  Future<List<ArticleListModel>> updateArticleList({
    required ArticleListModel articleList,
    required String label,
    required String card,
  });
  Future<List<ArticleListModel>> rerange({
    required int oldIndex,
    required int newIndex,
  });
  Future<List<ArticleListModel>> migrateArticleToMultipleList();
}

class ArticleRemoteDatasourceImpl implements ArticleRemoteDatasource {
  final SharedPreferences prefs;

  ArticleRemoteDatasourceImpl(this.prefs);

  @override
  Future<List<ArticleListModel>> getAll() async {
    bool hasKey = prefs.containsKey("articles");
    String? response = prefs.getString("articles");

    List<ArticleListModel> data = [];
    if (hasKey && response != null) {
      List<dynamic> articleList = jsonDecode(response);
      data =
          articleList.map((list) => ArticleListModel.fromJson(list)).toList();
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
  Future<List<ArticleListModel>> addArticle({
    required String id,
    required ArticleModel article,
  }) async {
    try {
      List<ArticleListModel> articleLists = await getAll();
      ArticleListModel articleList = articleLists.singleWhere(
        (l) => l.id == id,
      );
      List<ArticleModel> articles = articleList.articles;
      List<ArticleModel> exist =
          articles.where((a) => a.label == article.label).toList();
      if (exist.isEmpty) {
        articles.add(article);
        await prefs.setString(
          "articles",
          jsonEncode(articleLists.map((a) => a.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleListModel>> addList({
    required ArticleListModel articleList,
  }) async {
    try {
      List<ArticleListModel> articleLists = await getAll();
      List<ArticleListModel> exist =
          articleLists.where((a) => a.label == articleList.label).toList();
      if (exist.isEmpty) {
        articleLists.add(articleList);
        await prefs.setString(
          "articles",
          jsonEncode(articleLists.map((a) => a.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleListModel>> removeArticle({
    required String id,
    required ArticleModel article,
  }) async {
    try {
      List<ArticleListModel> articleLists = await getAll();
      ArticleListModel articleList = articleLists.singleWhere(
        (l) => l.id == id,
      );
      List<ArticleModel> articles = articleList.articles;
      articles.remove(article);
      await prefs.setString(
        "articles",
        jsonEncode(articleLists.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleListModel>> removeList({
    required ArticleListModel articleList,
  }) async {
    try {
      List<ArticleListModel> articleLists = await getAll();
      articleLists.remove(articleList);
      await prefs.setString(
        "articles",
        jsonEncode(articleLists.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleListModel>> toogleArticleDoneState({
    required String id,
    required ArticleModel article,
  }) async {
    try {
      List<ArticleListModel> articleLists = await getAll();
      ArticleListModel articleList = articleLists.singleWhere(
        (l) => l.id == id,
      );
      List<ArticleModel> articles = articleList.articles;
      int index = articles.indexOf(article);
      articles[index].done = !articles[index].done;
      await prefs.setString(
        "articles",
        jsonEncode(articleLists.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleListModel>> clear({
    required String id,
    required bool allArticle,
  }) async {
    try {
      if (allArticle) {
        List<ArticleListModel> articleLists = await getAll();
        ArticleListModel articleList = articleLists.singleWhere(
          (l) => l.id == id,
        );
        articleList.articles = [];
        await prefs.setString(
          "articles",
          jsonEncode(articleLists.map((a) => a.toJson()).toList()),
        );
      } else {
        List<ArticleListModel> articleLists = await getAll();
        ArticleListModel articleList = articleLists.singleWhere(
          (l) => l.id == id,
        );
        List<ArticleModel> articles = articleList.articles;
        articles.removeWhere((a) => a.done);
        await prefs.setString(
          "articles",
          jsonEncode(articleLists.map((a) => a.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ArticleListModel>> articleImport({
    required String json,
    required CategoryModel defaultCategory,
  }) async {
    try {
      Uuid uuid = Uuid();
      List<ArticleListModel> articleLists = await getAll();
      List<CategoryModel> categories = await getAllCategories();

      List<dynamic> data = jsonDecode(json);
      for (Map<String, dynamic> list in data) {
        list["id"] = uuid.v4();
        ArticleListModel articleList = ArticleListModel.fromMap(list);
        for (ArticleModel article in articleList.articles) {
          if (!categories.contains(article.category)) {
            article.category = defaultCategory;
          }
        }
        articleLists.add(articleList);
      }
      await prefs.setString(
        "articles",
        jsonEncode(articleLists.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleListModel>> updateArticle({
    required String id,
    required ArticleModel article,
    required String label,
    required CategoryModel category,
  }) async {
    try {
      List<ArticleListModel> articleLists = await getAll();
      ArticleListModel articleList = articleLists.singleWhere(
        (l) => l.id == id,
      );
      List<ArticleModel> articles = articleList.articles;
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
        jsonEncode(articleLists.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleListModel>> updateArticleList({
    required ArticleListModel articleList,
    required String label,
    required String card,
  }) async {
    try {
      List<ArticleListModel> articleLists = await getAll();
      int index = articleLists.indexOf(articleList);
      articleLists.removeAt(index);
      ArticleListModel updatedArticleList = ArticleListModel(
        id: articleList.id,
        label: label,
        card: card,
        articles: articleList.articles,
      );
      articleLists.insert(index, updatedArticleList);
      await prefs.setString(
        "articles",
        jsonEncode(articleLists.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<ArticleListModel>> rerange({
    required int oldIndex,
    required int newIndex,
  }) async {
    try {
      List<ArticleListModel> articlesLists = await getAll();
      final item = articlesLists.removeAt(oldIndex);
      articlesLists.insert(newIndex, item);
      await prefs.setString(
        "articles",
        jsonEncode(articlesLists.map((c) => c.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ArticleListModel>> migrateArticleToMultipleList() async {
    try {
      Uuid uuid = Uuid();
      bool hasKey = prefs.containsKey("articles");
      String? response = prefs.getString("articles");

      if (hasKey && response != null) {
        List<ArticleModel> articles = [];
        List<dynamic> articleList = jsonDecode(response);
        articles =
            articleList.map((list) => ArticleModel.fromJson(list)).toList();

        List<ArticleModel> migratedArticles = [];
        for (ArticleModel article in articles) {
          if (article.id == "") {
            ArticleModel newA = ArticleModel(
              id: uuid.v4(),
              label: article.label,
              category: article.category,
              done: article.done,
            );
            migratedArticles.add(newA);
          } else {
            migratedArticles.add(article);
          }
        }

        List<ArticleListModel> articleLists = [];
        articleLists.add(
          ArticleListModel(
            id: uuid.v4(),
            label: "Default",
            card: "",
            articles: migratedArticles,
          ),
        );
        await prefs.setString(
          "articles",
          jsonEncode(articleLists.map((a) => a.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }
}
