part of 'calculator_bloc.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object> get props => [];
}

class CalculatorGetAllEvent extends CalculatorEvent {}

class CalculatorGetAllWithArticleEvent extends CalculatorEvent {}

class CalculatorGetAllWithoutArticleEvent extends CalculatorEvent {}

class CalculatorAddEvent extends CalculatorEvent {
  final CalculatorModel value;

  const CalculatorAddEvent({required this.value});
}

class CalculatorAddWithoutArticleEvent extends CalculatorEvent {
  final String idList;
  final double price;

  const CalculatorAddWithoutArticleEvent({required this.idList, required this.price});
}

class CalculatorSubtractEvent extends CalculatorEvent {
  final CalculatorModel value;

  const CalculatorSubtractEvent({required this.value});
}

class CalculatorSubtractWithoutArticleEvent extends CalculatorEvent {
  final CalculatorModel value;

  const CalculatorSubtractWithoutArticleEvent({required this.value});
}

class CalculatorResetEvent extends CalculatorEvent {
  final String? idList;

  const CalculatorResetEvent({this.idList});
}

class CalculatorResetWithEvent extends CalculatorEvent {
  final String? idList;
  final List<ArticleModel> articles;
  
  const CalculatorResetWithEvent({this.idList, this.articles = const []});
}

class CalculatorResetWithoutArticleEvent extends CalculatorEvent {
  final String? idList;
  final List<String> articles;
  
  const CalculatorResetWithoutArticleEvent({this.idList, this.articles = const []});
}
