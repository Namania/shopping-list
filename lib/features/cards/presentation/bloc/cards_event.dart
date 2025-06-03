import 'package:equatable/equatable.dart';
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

class RemoveCardEvent extends CardEvent {
  final CardModel card;

  const RemoveCardEvent({required this.card});
}
