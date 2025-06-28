import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

// ignore: must_be_immutable
class Article extends Equatable {
  final String label;
  CategoryModel category;
  bool done;

  Article({
    required this.label,
    required this.category,
    required this.done
  });

  @override
  List<Object> get props => [label, category, done];

  @override
  bool get stringify => true;
}
