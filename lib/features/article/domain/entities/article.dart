import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class Article extends Equatable {
  final String label;
  final int quantity;
  bool done;

  Article({
    required this.label,
    required this.quantity,
    required this.done
  });

  @override
  List<Object> get props => [label, quantity, done];

  @override
  bool get stringify => true;
}
