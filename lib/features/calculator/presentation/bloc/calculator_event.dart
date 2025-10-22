part of 'calculator_bloc.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object> get props => [];
}

class CalculatorGetValueEvent extends CalculatorEvent {}

class CalculatorAddEvent extends CalculatorEvent {
  final double amount;

  const CalculatorAddEvent({required this.amount});
}

class CalculatorSubtractEvent extends CalculatorEvent {
  final double amount;

  const CalculatorSubtractEvent({required this.amount});
}

class CalculatorResetEvent extends CalculatorEvent {}
