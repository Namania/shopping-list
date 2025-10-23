import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/calculator/data/models/Calculator_model.dart';

abstract interface class CalculatorRemoteDatasource {
  Future<List<CalculatorModel>> getAll();
  Future<List<CalculatorModel>> add({required CalculatorModel value});
  Future<List<CalculatorModel>> subtract({required CalculatorModel value});
  Future<List<CalculatorModel>> reset({List<ArticleModel> articles = const []});
}

class CalculatorRemoteDatasourceImpl implements CalculatorRemoteDatasource {
  final SharedPreferences prefs;
  // ignore: constant_identifier_names
  static const String STORED_KEY = "calculator";

  CalculatorRemoteDatasourceImpl(this.prefs);

  
  @override
  Future<List<CalculatorModel>> getAll() async {
    bool hasKey = prefs.containsKey(STORED_KEY);

    List<CalculatorModel> data = [];
    if (hasKey) {
      String? response = prefs.getString(STORED_KEY);
      if (response != null) {
        List<dynamic> calculators = jsonDecode(response);
        data = calculators.map((c) => CalculatorModel.fromJson(c)).toList();
      }
    }

    return data;
  }
  
  @override
  Future<List<CalculatorModel>> add({required CalculatorModel value}) async {
    try {
      List<CalculatorModel> data = await getAll();
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
  Future<List<CalculatorModel>> subtract({required CalculatorModel value}) async {
    try {
      List<CalculatorModel> data = await getAll();
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
  Future<List<CalculatorModel>> reset({List<ArticleModel> articles = const []}) async {
    try {
      if (articles.isEmpty) {
        prefs.setString(STORED_KEY, "[]");
      } else {
        List<CalculatorModel> data = await getAll();
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
}
