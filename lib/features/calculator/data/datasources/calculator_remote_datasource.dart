import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/calculator/data/models/calculator_model.dart';
import 'package:uuid/uuid.dart';

abstract interface class CalculatorRemoteDatasource {
  Future<List<CalculatorModel>> getAll();
  Future<List<CalculatorModel>> getAllWithArticle();
  Future<List<CalculatorModel>> getAllWithoutArticle();
  Future<List<CalculatorModel>> add({required CalculatorModel value});
  Future<List<CalculatorModel>> addWithoutArticle({required double price});
  Future<List<CalculatorModel>> subtract({required CalculatorModel value});
  Future<List<CalculatorModel>> subtractWithoutArticle({required CalculatorModel value});
  Future<List<CalculatorModel>> reset();
  Future<List<CalculatorModel>> resetWith({List<ArticleModel> articles = const []});
  Future<List<CalculatorModel>> resetWithoutArticle({List<String> articles = const []});
}

class CalculatorRemoteDatasourceImpl implements CalculatorRemoteDatasource {
  final SharedPreferences prefs;
  final Uuid uuid;
  // ignore: constant_identifier_names
  static const String STORED_KEY = "calculator";
  // ignore: constant_identifier_names
  static const String STORED_WITHOUT_ARTICLE_KEY = "calculator_without_article";

  CalculatorRemoteDatasourceImpl(this.prefs, this.uuid);

  @override
  Future<List<CalculatorModel>> getAll() async {
    List<CalculatorModel> data = [];
    data.addAll(await getAllWithArticle());
    data.addAll(await getAllWithoutArticle());
    return data;
  }

  @override
  Future<List<CalculatorModel>> getAllWithArticle() async {
    bool hasKey = prefs.containsKey(STORED_KEY);

    List<CalculatorModel> data = [];
    if (hasKey) {
      String? response = prefs.getString(STORED_KEY);
      if (response != null) {
        List<dynamic> calculators = jsonDecode(response);
        data.addAll(calculators.map((c) => CalculatorModel.fromJson(c)).toList());
      }
    }

    return data;
  }

  @override
  Future<List<CalculatorModel>> getAllWithoutArticle() async {
    bool hasWithoutArticleKey = prefs.containsKey(STORED_WITHOUT_ARTICLE_KEY);

    List<CalculatorModel> data = [];
    if (hasWithoutArticleKey) {
      String? responseWithoutArticle = prefs.getString(STORED_WITHOUT_ARTICLE_KEY);
      if (responseWithoutArticle != null) {
        List<dynamic> calculatorsWithoutArticle = jsonDecode(responseWithoutArticle);
        data.addAll(calculatorsWithoutArticle.map((c) => CalculatorModel.fromJson(c)).toList());
      }
    }

    return data;
  }
  
  @override
  Future<List<CalculatorModel>> add({required CalculatorModel value}) async {
    try {
      List<CalculatorModel> data = await getAllWithArticle();
      List<CalculatorModel> exist =
          data.where((a) => a.idArticle == value.idArticle).toList();
      if (exist.isEmpty) {
        data.add(CalculatorModel(
          idArticle: value.idArticle,
          price: value.price * 100
        ));
        await prefs.setString(
          STORED_KEY,
          jsonEncode(data.map((c) => c.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }
  
  @override
  Future<List<CalculatorModel>> addWithoutArticle({required double price}) async {
    try {
      List<CalculatorModel> data = await getAllWithoutArticle();
      String id = uuid.v4();
      List<CalculatorModel> exist =
          data.where((a) => a.idArticle == id).toList();
      if (exist.isEmpty) {
        data.add(CalculatorModel(
          idArticle: id,
          price: price * 100
        ));
        await prefs.setString(
          STORED_WITHOUT_ARTICLE_KEY,
          jsonEncode(data.map((c) => c.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }
  
  @override
  Future<List<CalculatorModel>> subtract({required CalculatorModel value}) async {
    try {
      List<CalculatorModel> data = await getAllWithArticle();
      data.removeWhere((c) => c.idArticle == value.idArticle);
      await prefs.setString(
        STORED_KEY,
        jsonEncode(data.map((c) => c.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }
  
  @override
  Future<List<CalculatorModel>> subtractWithoutArticle({required CalculatorModel value}) async {
    try {
      List<CalculatorModel> data = await getAllWithoutArticle();
      data.removeWhere((c) => c.idArticle == value.idArticle);
      await prefs.setString(
        STORED_WITHOUT_ARTICLE_KEY,
        jsonEncode(data.map((c) => c.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<CalculatorModel>> reset() async {
    try {
      await resetWith();
      await resetWithoutArticle();
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<CalculatorModel>> resetWith({List<ArticleModel> articles = const []}) async {
    try {
      if (articles.isEmpty) {
        prefs.setString(STORED_KEY, "[]");
      } else {
        List<CalculatorModel> data = await getAllWithArticle();
        List<String> uuid = articles.where((a) => a.done).map((a) => a.id).toList();
        data.removeWhere((c) => uuid.contains(c.idArticle));
        await prefs.setString(
          STORED_KEY,
          jsonEncode(data.map((c) => c.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<CalculatorModel>> resetWithoutArticle({List<String> articles = const []}) async {
    try {
      if (articles.isEmpty) {
        prefs.setString(STORED_WITHOUT_ARTICLE_KEY, "[]");
      } else {
        List<CalculatorModel> data = await getAllWithoutArticle();
        data.removeWhere((c) => articles.contains(c.idArticle));
        await prefs.setString(
          STORED_WITHOUT_ARTICLE_KEY,
          jsonEncode(data.map((c) => c.toJson()).toList()),
        );
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }
}
