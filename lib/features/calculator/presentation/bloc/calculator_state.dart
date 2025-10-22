part of 'calculator_bloc.dart';

abstract class CalculatorState extends Equatable {
  const CalculatorState();  

  @override
  List<Object> get props => [];
}
class CalculatorInitial extends CalculatorState {}

class CalculatorSuccess extends CalculatorState {
  final double value;

  const CalculatorSuccess({required this.value});
}

final class CalculatorFailure extends CalculatorState {
  final String message;

  const CalculatorFailure({required this.message});
}

class CalculatorLoading extends CalculatorState {}
