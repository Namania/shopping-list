import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';

// ignore: must_be_immutable
class ArticleList extends Equatable {
  final String id;
  final String label;
  final String card;
  List<ArticleModel> articles;

  ArticleList({
    required this.id,
    required this.label,
    required this.card,
    required this.articles,
  });

  @override
  List<Object> get props => [id, label, card, articles];

  @override
  bool get stringify => true;
}
