import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';

// ignore: must_be_immutable
class ArticleList extends Equatable {
  final String id;
  final String label;
  List<ArticleModel> articles;

  ArticleList({
    required this.id,
    required this.label,
    required this.articles,
  });

  @override
  List<Object> get props => [id, label, articles];

  @override
  bool get stringify => true;
}
