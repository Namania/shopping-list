import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Card extends Equatable {
  final String id;
  final String label;
  final String code;
  final Color color;

  const Card({
    required this.id,
    required this.label,
    required this.code,
    required this.color,
  });

  @override
  List<Object> get props => [id, label, code, color];

  @override
  bool get stringify => true;
}
