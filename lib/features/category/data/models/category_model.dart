import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/features/category/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({required super.label, required super.color});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'label': label, 'color': color.toARGB32()};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      label: map['label'] as String,
      color: Color(map['color']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
