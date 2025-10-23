part of 'calculator_bloc.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object> get props => [];
}

class CalculatorGetAllEvent extends CalculatorEvent {}

class CalculatorAddEvent extends CalculatorEvent {
  final CalculatorModel value;

  const CalculatorAddEvent({required this.value});
}

class CalculatorSubtractEvent extends CalculatorEvent {
  final CalculatorModel value;

  const CalculatorSubtractEvent({required this.value});
}

class CalculatorResetEvent extends CalculatorEvent {
  final List<ArticleModel> articles;
  
  const CalculatorResetEvent({this.articles = const []});
}
