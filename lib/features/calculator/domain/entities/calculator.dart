import 'package:equatable/equatable.dart';

class Calculator extends Equatable {
  final String idList;
  final String idArticle;
  final double price;

  const Calculator({
    required this.idList,
    required this.idArticle,
    required this.price
  });

  @override
  List<Object> get props => [idList, idArticle, price];

  @override
  bool get stringify => true;
}
