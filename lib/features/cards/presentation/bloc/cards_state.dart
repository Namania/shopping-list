import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';

abstract class CardState extends Equatable {
  const CardState();  

  @override
  List<Object> get props => [];
}

class CardInitial extends CardState {}

class CardSuccess extends CardState {
  final List<CardModel> cards;

  const CardSuccess({required this.cards});
}

final class CardFailure extends CardState {
  final String message;

  const CardFailure({required this.message});
}

class CardLoading extends CardState {}
