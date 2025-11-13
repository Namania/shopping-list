part of 'article_bloc.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object> get props => [];
}

class ArticleGetAllEvent extends ArticleEvent {}

class AddArticleEvent extends ArticleEvent {
  final String id;
  final ArticleModel article;

  const AddArticleEvent({required this.id, required this.article});
}

class AddListEvent extends ArticleEvent {
  final ArticleListModel articleList;

  const AddListEvent({required this.articleList});
}

class UpdateArticleEvent extends ArticleEvent {
  final String id;
  final ArticleModel article;
  final String label;
  final CategoryModel category;

  const UpdateArticleEvent({
    required this.id,
    required this.article,
    required this.label,
    required this.category,
  });
}

class ArticleImportEvent extends ArticleEvent {
  final String json;
  final CategoryModel defaultCategory;

  const ArticleImportEvent({
    required this.json,
    required this.defaultCategory,
  });
}

class RemoveArticleEvent extends ArticleEvent {
  final String id;
  final ArticleModel article;

  const RemoveArticleEvent({required this.id, required this.article});
}

class RemoveListEvent extends ArticleEvent {
  final ArticleListModel articleList;

  const RemoveListEvent({required this.articleList});
}

class ClearEvent extends ArticleEvent {
  final String id;
  final bool allArticle;

  const ClearEvent({required this.id, required this.allArticle});
}

class ToogleArticleDoneStateEvent extends ArticleEvent {
  final String id;
  final ArticleModel article;

  const ToogleArticleDoneStateEvent({required this.id, required this.article});
}

class ArticleMigrateIdEvent extends ArticleEvent {}

class ArticleMigrateToMultipleListEvent extends ArticleEvent {}
