part of 'article_bloc.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object> get props => [];
}

class ArticleGetAllEvent extends ArticleEvent {}

class AddArticleEvent extends ArticleEvent {
  final ArticleModel article;

  const AddArticleEvent({required this.article});
}

class UpdateArticleEvent extends ArticleEvent {
  final ArticleModel article;
  final String label;
  final CategoryModel category;

  const UpdateArticleEvent({
    required this.article,
    required this.label,
    required this.category,
  });
}

class ArticleImportEvent extends ArticleEvent {
  final String json;
  final CategoryModel defaultCategory;

  const ArticleImportEvent({required this.json, required this.defaultCategory});
}

class RemoveArticleEvent extends ArticleEvent {
  final ArticleModel article;

  const RemoveArticleEvent({required this.article});
}

class ClearEvent extends ArticleEvent {
  final bool allArticle;

  const ClearEvent({required this.allArticle});
}

class ToogleArticleDoneStateEvent extends ArticleEvent {
  final ArticleModel article;

  const ToogleArticleDoneStateEvent({required this.article});
}
