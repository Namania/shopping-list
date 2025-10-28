import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_add_without_article.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_get_all.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_get_all_with_article.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_get_all_without_article.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_reset_without_article.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_subtract_without_article.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../article/data/models/article_model.dart';
import '../../data/models/calculator_model.dart';
import '../../domain/usecases/calculator_add.dart';
import '../../domain/usecases/calculator_reset.dart';
import '../../domain/usecases/calculator_reset_with.dart';
import '../../domain/usecases/calculator_subtract.dart';

part 'calculator_event.dart';
part 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {

  final CalculatorGetAll getAll;
  final CalculatorGetAllWithArticle getAllWithArticle;
  final CalculatorGetAllWithoutArticle getAllWithoutArticle;
  final CalculatorAdd calculatorAdd;
  final CalculatorAddWithoutArticle calculatorAddWithoutArticle;
  final CalculatorSubtract calculatorSubtract;
  final CalculatorSubtractWithoutArticle calculatorSubtractWithoutArticle;
  final CalculatorReset calculatorReset;
  final CalculatorResetWith calculatorResetWith;
  final CalculatorResetWithoutArticle calculatorResetWithoutArticle;

  CalculatorBloc({
    required this.getAll,
    required this.getAllWithArticle,
    required this.getAllWithoutArticle,
    required this.calculatorAdd,
    required this.calculatorAddWithoutArticle,
    required this.calculatorSubtract,
    required this.calculatorSubtractWithoutArticle,
    required this.calculatorReset,
    required this.calculatorResetWith,
    required this.calculatorResetWithoutArticle,
  }) : super(CalculatorInitial()) {
    on<CalculatorEvent>((event, emit) {
      emit(CalculatorLoading());
    });
    on<CalculatorGetAllEvent>((event, emit) => _onCalculatorGetAll(event, emit));
    on<CalculatorGetAllWithArticleEvent>((event, emit) => _onCalculatorGetAllWithArticle(event, emit));
    on<CalculatorGetAllWithoutArticleEvent>((event, emit) => _onCalculatorGetAllWithoutArticle(event, emit));
    on<CalculatorAddEvent>((event, emit) => _onCalculatorAdd(event, emit));
    on<CalculatorAddWithoutArticleEvent>((event, emit) => _onCalculatorAddWithoutArticle(event, emit));
    on<CalculatorSubtractEvent>((event, emit) => _onCalculatorSubtract(event, emit));
    on<CalculatorSubtractWithoutArticleEvent>((event, emit) => _onCalculatorSubtractWithoutArticle(event, emit));
    on<CalculatorResetEvent>((event, emit) => _onCalculatorReset(event, emit));
    on<CalculatorResetWithEvent>((event, emit) => _onCalculatorResetWith(event, emit));
    on<CalculatorResetWithoutArticleEvent>((event, emit) => _onCalculatorResetWithoutArticle(event, emit));
    add(CalculatorGetAllEvent());
  }
  
  Future<void> _onCalculatorGetAll(CalculatorGetAllEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await getAll(NoParams());

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }
  
  Future<void> _onCalculatorGetAllWithArticle(CalculatorGetAllWithArticleEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await getAllWithArticle(NoParams());

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }
  
  Future<void> _onCalculatorGetAllWithoutArticle(CalculatorGetAllWithoutArticleEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await getAllWithoutArticle(NoParams());

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }
  
  Future<void> _onCalculatorAdd(CalculatorAddEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorAdd(CalculatorAddParams(value: event.value));

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }
  
  Future<void> _onCalculatorAddWithoutArticle(CalculatorAddWithoutArticleEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorAddWithoutArticle(CalculatorAddWithoutArticleParams(price: event.price));

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }
  
  Future<void> _onCalculatorSubtract(CalculatorSubtractEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorSubtract(CalculatorSubtractParams(value: event.value));

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }
  
  Future<void> _onCalculatorSubtractWithoutArticle(CalculatorSubtractWithoutArticleEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorSubtractWithoutArticle(CalculatorSubtractWithoutArticleParams(value: event.value));

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }
  
  Future<void> _onCalculatorReset(CalculatorResetEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorReset(NoParams());

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }
  
  Future<void> _onCalculatorResetWith(CalculatorResetWithEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorResetWith(CalculatorResetWithParams(articles: event.articles));

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }
  
  Future<void> _onCalculatorResetWithoutArticle(CalculatorResetWithoutArticleEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorResetWithoutArticle(CalculatorResetWithoutArticleParams(articles: event.articles));

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(data: r)),
    );
  }

  double? getValue() {
    if (state is CalculatorSuccess) {
      double amount = 0;
      for (CalculatorModel model in (state as CalculatorSuccess).data) {
        amount += model.price;
      }
      return amount / 100;
    }
    return null;
  }

  List<CalculatorModel> getAllCalculator() {
    if (state is CalculatorSuccess) {
      return (state as CalculatorSuccess).data;
    }
    return [];
  }
}
