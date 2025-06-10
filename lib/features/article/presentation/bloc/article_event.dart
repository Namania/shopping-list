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

class ArticleImportEvent extends ArticleEvent {
  final String json;

  const ArticleImportEvent({required this.json});
}

class RemoveArticleEvent extends ArticleEvent {
  final int index;

  const RemoveArticleEvent({required this.index});
}

class ClearEvent extends ArticleEvent {
  final bool allArticle;

  const ClearEvent({required this.allArticle});
}

class ToogleArticleDoneStateEvent extends ArticleEvent {
  final int index;

  const ToogleArticleDoneStateEvent({required this.index});
}
