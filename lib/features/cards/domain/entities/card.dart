import 'package:equatable/equatable.dart';

class Card extends Equatable {
  final String label;
  final String code;

  const Card({
    required this.label,
    required this.code,
  });

  @override
  List<Object> get props => [label, code];

  @override
  bool get stringify => true;
}
