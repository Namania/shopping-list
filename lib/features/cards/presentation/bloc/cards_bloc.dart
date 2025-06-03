import 'package:bloc/bloc.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/cards/domain/usecases/add_card.dart';
import 'package:shopping_list/features/cards/domain/usecases/card_get_all.dart';
import 'package:shopping_list/features/cards/domain/usecases/remove_card%20copy.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final CardGetAll cardGetAll;
  final AddCard addCard;
  final RemoveCard removeCard;

  CardBloc({
    required this.cardGetAll,
    required this.addCard,
    required this.removeCard,
  }) : super(CardInitial()) {
    on<CardEvent>((event, emit) {
      emit(CardLoading());
    });
    on<CardGetAllEvent>(
      (event, emit) => _onCardGetAll(event, emit),
    );
    on<AddCardEvent>(
      (event, emit) => _onAddCardEvent(event, emit),
    );
    on<RemoveCardEvent>(
      (event, emit) => _onRemoveCard(event, emit),
    );
    add(CardGetAllEvent());
  }

  Future<void> _onCardGetAll(
    CardGetAllEvent event,
    Emitter emit,
  ) async {
    emit(CardLoading());
    final result = await cardGetAll(NoParams());

    result.fold(
      (l) => emit(CardFailure(message: l.message)),
      (r) => emit(CardSuccess(cards: r)),
    );
  }

  Future<void> _onAddCardEvent(
    AddCardEvent event,
    Emitter emit,
  ) async {
    emit(CardLoading());
    final result = await addCard(
      AddCardParams(card: event.card)
    );

    result.fold(
      (l) => emit(CardFailure(message: l.message)),
      (r) => emit(CardSuccess(cards: r)),
    );
  }
  
  Future<void> _onRemoveCard(
    RemoveCardEvent event,
    Emitter emit,
  ) async {
    emit(CardLoading());
    final result = await removeCard(
      RemoveCardParams(card: event.card)
    );

    result.fold(
      (l) => emit(CardFailure(message: l.message)),
      (r) => emit(CardSuccess(cards: r)),
    );
  }

}
