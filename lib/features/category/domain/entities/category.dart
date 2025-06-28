import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final String label;
  final Color color;

  const Category({required this.label, required this.color});

  @override
  List<Object> get props => [label, color];

  @override
  bool get stringify => true;
}
