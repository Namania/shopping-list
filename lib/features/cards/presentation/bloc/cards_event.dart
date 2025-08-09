import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';

abstract class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object> get props => [];
}

class CardGetAllEvent extends CardEvent {}

class AddCardEvent extends CardEvent {
  final CardModel card;

  const AddCardEvent({required this.card});
}

class UpdateCardEvent extends CardEvent {
  final CardModel card;
  final String label;
  final String code;
  final Color color;

  const UpdateCardEvent({
    required this.card,
    required this.label,
    required this.code,
    required this.color,
  });
}

class RemoveCardEvent extends CardEvent {
  final CardModel card;

  const RemoveCardEvent({required this.card});
}

class CardImportEvent extends CardEvent {
  final String json;

  const CardImportEvent({required this.json});
}

class RerangeCardEvent extends CardEvent {
  final int oldIndex;
  final int newIndex;

  const RerangeCardEvent({
    required this.oldIndex,
    required this.newIndex,
  });
}
