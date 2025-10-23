import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/calculator/domain/usecases/calculator_get_all.dart';

import '../../../../core/usecase/usecase.dart';
import '../../data/models/Calculator_model.dart';
import '../../domain/usecases/calculator_add.dart';
import '../../domain/usecases/calculator_reset.dart';
import '../../domain/usecases/calculator_subtract.dart';

part 'calculator_event.dart';
part 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {

  final CalculatorGetAll getAll;
  final CalculatorAdd calculatorAdd;
  final CalculatorSubtract calculatorSubtract;
  final CalculatorReset calculatorReset;

  CalculatorBloc({
    required this.getAll,
    required this.calculatorAdd,
    required this.calculatorSubtract,
    required this.calculatorReset,
  }) : super(CalculatorInitial()) {
    on<CalculatorEvent>((event, emit) {
      emit(CalculatorLoading());
    });
    on<CalculatorGetAllEvent>((event, emit) => _onCalculatorGetAll(event, emit));
    on<CalculatorAddEvent>((event, emit) => _onCalculatorAdd(event, emit));
    on<CalculatorSubtractEvent>((event, emit) => _onCalculatorSubtract(event, emit));
    on<CalculatorResetEvent>((event, emit) => _onCalculatorReset(event, emit));
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
  
  Future<void> _onCalculatorAdd(CalculatorAddEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorAdd(CalculatorAddParams(value: event.value));

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
  
  Future<void> _onCalculatorReset(CalculatorResetEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorReset(NoParams());

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
