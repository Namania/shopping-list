import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final String id;
  final String label;
  final Color color;

  const Category({required this.id, required this.label, required this.color});

  Category copyWith({String? label, Color? color}) =>
      Category(id: id, label: label ?? this.label, color: color ?? this.color);

  /// Categories are matched across devices by their label and color: this is
  /// how the share, import and backup formats identify them.
  bool sameAs(Category other) => label == other.label && color == other.color;

  /// Share / backup format (no id, kept compatible with older app versions).
  Map<String, dynamic> toMap() => {'label': label, 'color': color.toARGB32()};

  factory Category.fromMap(Map<String, dynamic> map, {required String id}) =>
      Category(id: id, label: map['label'] as String, color: Color(map['color'] as int));

  @override
  List<Object?> get props => [id, label, color];
}
