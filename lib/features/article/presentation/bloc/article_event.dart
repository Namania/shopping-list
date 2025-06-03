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

class RemoveArticleEvent extends ArticleEvent {
  final ArticleModel article;

  const RemoveArticleEvent({required this.article});
}

class ClearEvent extends ArticleEvent {}

class ToogleArticleDoneStateEvent extends ArticleEvent {
  final ArticleModel article;

  const ToogleArticleDoneStateEvent({required this.article});
}
