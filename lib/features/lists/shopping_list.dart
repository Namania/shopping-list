import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/lists/article.dart';

class ShoppingList extends Equatable {
  final String id;
  final String label;

  /// Linked loyalty card, if any.
  final String? cardId;
  final List<Article> articles;

  const ShoppingList({required this.id, required this.label, this.cardId, this.articles = const []});

  ShoppingList copyWith({String? label, String? cardId, bool clearCard = false}) => ShoppingList(
    id: id,
    label: label ?? this.label,
    cardId: clearCard ? null : (cardId ?? this.cardId),
    articles: articles,
  );

  /// Share / backup format, kept compatible with older app versions.
  Map<String, dynamic> toMap({required Category uncategorized}) => {
    'id': id,
    'label': label,
    'card': cardId ?? '',
    'articles': articles.map((a) => a.toMap(uncategorized: uncategorized)).toList(),
  };

  @override
  List<Object?> get props => [id, label, cardId, articles];
}
