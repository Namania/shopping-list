import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class Article extends Equatable {
  final String label;
  final int quantity;
  bool done = false;

  Article({
    required this.label,
    required this.quantity,
  });

  @override
  List<Object> get props => [label, quantity, done];

  @override
  bool get stringify => true;
}
