import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/calculator/domain/usecases/get_value.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/calculator_add.dart';
import '../../domain/usecases/calculator_reset.dart';
import '../../domain/usecases/calculator_subtract.dart';

part 'calculator_event.dart';
part 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {

  final GetValue getValue;
  final CalculatorAdd calculatorAdd;
  final CalculatorSubtract calculatorSubtract;
  final CalculatorReset calculatorReset;

  CalculatorBloc({
    required this.getValue,
    required this.calculatorAdd,
    required this.calculatorSubtract,
    required this.calculatorReset,
  }) : super(CalculatorInitial()) {
    on<CalculatorEvent>((event, emit) {
      emit(CalculatorLoading());
    });
    on<CalculatorGetValueEvent>((event, emit) => _onCalculatorGetValue(event, emit));
    on<CalculatorAddEvent>((event, emit) => _onCalculatorAdd(event, emit));
    on<CalculatorSubtractEvent>((event, emit) => _onCalculatorSubtract(event, emit));
    on<CalculatorResetEvent>((event, emit) => _onCalculatorReset(event, emit));
    add(CalculatorGetValueEvent());
  }
  
  Future<void> _onCalculatorGetValue(CalculatorGetValueEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await getValue(NoParams());

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(value: r)),
    );
  }
  
  Future<void> _onCalculatorAdd(CalculatorAddEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorAdd(CalculatorAddParams(amount: event.amount));

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(value: r)),
    );
  }
  
  Future<void> _onCalculatorSubtract(CalculatorSubtractEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorSubtract(CalculatorSubtractParams(amount: event.amount));

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(value: r)),
    );
  }
  
  Future<void> _onCalculatorReset(CalculatorResetEvent event, Emitter emit) async {
    emit(CalculatorLoading());
    final result = await calculatorReset(NoParams());

    result.fold(
      (l) => emit(CalculatorFailure(message: l.message)),
      (r) => emit(CalculatorSuccess(value: r)),
    );
  }
}
