import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/utils/colors.dart';
import 'package:shopping_list/features/cards/card_format.dart';

class LoyaltyCard extends Equatable {
  final String id;
  final String label;
  final String code;
  final Color color;
  final CardFormat format;

  const LoyaltyCard({
    required this.id,
    required this.label,
    required this.code,
    required this.color,
    this.format = CardFormat.code128,
  });

  LoyaltyCard copyWith({String? label, String? code, Color? color, CardFormat? format}) => LoyaltyCard(
    id: id,
    label: label ?? this.label,
    code: code ?? this.code,
    color: color ?? this.color,
    format: format ?? this.format,
  );

  /// Share / backup format, kept compatible with older app versions (which
  /// ignore `format`).
  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'code': code,
    'color': color.toARGB32(),
    'format': format.name,
  };

  factory LoyaltyCard.fromMap(Map<String, dynamic> map, {required String fallbackId}) => LoyaltyCard(
    id: (map['id'] as String?) ?? fallbackId,
    label: map['label'] as String,
    code: map['code'].toString(),
    color: opaqueColor(map['color'] as int?),
    format: CardFormat.fromName(map['format'] as String?),
  );

  @override
  List<Object?> get props => [id, label, code, color, format];
}
