import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/categories/category.dart';

class Article extends Equatable {
  final String id;
  final String listId;
  final String label;
  final bool done;

  /// `null` means "uncategorized".
  final Category? category;

  const Article({
    required this.id,
    required this.listId,
    required this.label,
    this.done = false,
    this.category,
  });

  Article copyWith({String? label, bool? done, Category? category, bool clearCategory = false}) => Article(
    id: id,
    listId: listId,
    label: label ?? this.label,
    done: done ?? this.done,
    category: clearCategory ? null : (category ?? this.category),
  );

  /// Share / backup format. An uncategorized article is written with the
  /// placeholder category older versions expect, and read back as `null`.
  Map<String, dynamic> toMap({required Category uncategorized}) => {
    'id': id,
    'label': label,
    'category': (category ?? uncategorized).toMap(),
    'done': done,
  };

  @override
  List<Object?> get props => [id, listId, label, done, category];
}
