import 'package:equatable/equatable.dart';

class Calculator extends Equatable {
  final String idArticle;
  final double price;

  const Calculator({
    required this.idArticle,
    required this.price
  });

  @override
  List<Object> get props => [idArticle, price];

  @override
  bool get stringify => true;
}
