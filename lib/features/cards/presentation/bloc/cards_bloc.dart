import 'package:bloc/bloc.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/domain/usecases/add_card.dart';
import 'package:shopping_list/features/cards/domain/usecases/card_get_all.dart';
import 'package:shopping_list/features/cards/domain/usecases/card_import.dart';
import 'package:shopping_list/features/cards/domain/usecases/remove_card.dart';
import 'package:shopping_list/features/cards/domain/usecases/update_card.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final CardGetAll cardGetAll;
  final AddCard addCard;
  final UpdateCard updateCard;
  final RemoveCard removeCard;
  final CardImport cardImport;

  CardBloc({
    required this.cardGetAll,
    required this.addCard,
    required this.updateCard,
    required this.removeCard,
    required this.cardImport,
  }) : super(CardInitial()) {
    on<CardEvent>((event, emit) {
      emit(CardLoading());
    });
    on<CardGetAllEvent>((event, emit) => _onCardGetAll(event, emit));
    on<AddCardEvent>((event, emit) => _onAddCardEvent(event, emit));
    on<UpdateCardEvent>((event, emit) => _onUpdateCardEvent(event, emit));
    on<RemoveCardEvent>((event, emit) => _onRemoveCard(event, emit));
    on<CardImportEvent>((event, emit) => _onCardImport(event, emit));
    add(CardGetAllEvent());
  }

  Future<void> _onCardGetAll(CardGetAllEvent event, Emitter emit) async {
    emit(CardLoading());
    final result = await cardGetAll(NoParams());

    result.fold(
      (l) => emit(CardFailure(message: l.message)),
      (r) => emit(CardSuccess(cards: r)),
    );
  }

  Future<void> _onAddCardEvent(AddCardEvent event, Emitter emit) async {
    emit(CardLoading());
    final result = await addCard(AddCardParams(card: event.card));

    result.fold(
      (l) => emit(CardFailure(message: l.message)),
      (r) => emit(CardSuccess(cards: r)),
    );
  }

  Future<void> _onRemoveCard(RemoveCardEvent event, Emitter emit) async {
    emit(CardLoading());
    final result = await removeCard(RemoveCardParams(card: event.card));

    result.fold(
      (l) => emit(CardFailure(message: l.message)),
      (r) => emit(CardSuccess(cards: r)),
    );
  }

  Future<void> _onCardImport(CardImportEvent event, Emitter emit) async {
    emit(CardLoading());
    final result = await cardImport(CardImportParams(json: event.json));

    result.fold(
      (l) => emit(CardFailure(message: l.message)),
      (r) => emit(CardSuccess(cards: r)),
    );
  }

  Future<void> _onUpdateCardEvent(UpdateCardEvent event, Emitter emit) async {
    emit(CardLoading());
    final result = await updateCard(
      UpdateCardParams(card: event.card, label: event.label, code: event.code, color: event.color),
    );

    result.fold(
      (l) => emit(CardFailure(message: l.message)),
      (r) => emit(CardSuccess(cards: r)),
    );
  }

  List<CardModel> getAllCard() {
    if (state is CardSuccess) {
      return (state as CardSuccess).cards.toList();
    }
    return [];
  }
}
