import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

abstract interface class CategoryRemoteDatasource {
  Future<List<CategoryModel>> getAll();
  Future<List<CategoryModel>> addCategory({
    required CategoryModel category,
  });
  Future<List<CategoryModel>> removeCategory({required int index});
  Future<List<CategoryModel>> updateCategory({
    required CategoryModel category,
    required String label,
    required Color color,
  });
  Future<List<CategoryModel>> categoryImport({
    required String json
  });
  Future<List<CategoryModel>> clear();
}

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final SharedPreferences prefs;

  CategoryRemoteDatasourceImpl(this.prefs);

  @override
  Future<List<CategoryModel>> getAll() async {
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
  Future<List<CategoryModel>> addCategory({
    required CategoryModel category,
  }) async {
    try {
      List<CategoryModel> categories = await getAll();
      categories.add(category);
      await prefs.setString("categories", jsonEncode(categories.map((a) => a.toJson()).toList()));
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<CategoryModel>> removeCategory({required int index}) async {
    try {
      List<CategoryModel> categories = await getAll();
      categories.removeAt(index);
      await prefs.setString(
        "categories",
        jsonEncode(categories.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<CategoryModel>> updateCategory({
    required CategoryModel category,
    required String label,
    required Color color,
  }) async {
    try {
      List<CategoryModel> categories = await getAll();
      int index = categories.indexOf(category);
      categories.removeAt(index);
      CategoryModel updatedCategory = CategoryModel(label: label, color: color);
      categories.insert(index, updatedCategory);
      await prefs.setString(
        "categories",
        jsonEncode(categories.map((a) => a.toJson()).toList()),
      );
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }
  
  @override
  Future<List<CategoryModel>> categoryImport({
    required String json
  }) async {
    try {
      List<CategoryModel> categories = await getAll();

      List<dynamic> data = jsonDecode(json);
      for (Map<String, dynamic> element in data) {
        CategoryModel category = CategoryModel.fromMap(element);
        if (!categories.contains(category)) {
          await addCategory(category: category);
        }
      }
      return await getAll();
    } catch (e) {
      return await getAll();
    }
  }

  @override
  Future<List<CategoryModel>> clear() async {
    try {
      await prefs.setString("categories", "[]");
      return await getAll();
    } catch (e) {
      return [];
    }
  }
}
