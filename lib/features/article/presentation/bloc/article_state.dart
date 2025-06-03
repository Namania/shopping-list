part of 'article_bloc.dart';

abstract class ArticleState extends Equatable {
  const ArticleState();  

  @override
  List<Object> get props => [];
}

class ArticleInitial extends ArticleState {}

class ArticleSuccess extends ArticleState {
  final List<Article> articles;

  const ArticleSuccess({required this.articles});
}

final class ArticleFailure extends ArticleState {
  final String message;

  const ArticleFailure({required this.message});
}

class ArticleLoading extends ArticleState {}
