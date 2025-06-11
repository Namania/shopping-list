import 'package:bloc/bloc.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/usecases/add_article_from_map.dart';
import 'package:shopping_list/features/article/domain/usecases/article_import.dart';
import 'package:shopping_list/features/article/domain/usecases/remove_article_from_map%20copy.dart';
import 'package:shopping_list/features/article/domain/usecases/clear.dart';
import 'package:shopping_list/features/article/domain/usecases/get_all.dart';
import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/article/domain/usecases/toogle_article_done_state.dart';
import 'package:shopping_list/features/article/domain/usecases/update_article.dart';

part 'article_event.dart';
part 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final GetAll getAll;
  final AddArticle addArticle;
  final UpdateArticle updateArticle;
  final RemoveArticle removeArticle;
  final ToogleArticleDoneState toogleArticleDoneState;
  final Clear clear;
  final ArticleImport articleImport;

  ArticleBloc({
    required this.getAll,
    required this.addArticle,
    required this.updateArticle,
    required this.removeArticle,
    required this.toogleArticleDoneState,
    required this.clear,
    required this.articleImport,
  }) : super(ArticleInitial()) {
    on<ArticleEvent>((event, emit) {
      emit(ArticleLoading());
    });
    on<ArticleGetAllEvent>((event, emit) => _onGetAll(event, emit));
    on<AddArticleEvent>((event, emit) => _onAddArticle(event, emit));
    on<UpdateArticleEvent>((event, emit) => _onUpdateArticle(event, emit));
    on<RemoveArticleEvent>((event, emit) => _onRemoveArticle(event, emit));
    on<ClearEvent>((event, emit) => _onClear(event, emit));
    on<ToogleArticleDoneStateEvent>(
      (event, emit) => _onToogleArticleDoneState(event, emit),
    );
    on<ArticleImportEvent>((event, emit) => _onArticleImport(event, emit));
    add(ArticleGetAllEvent());
  }

  Future<void> _onGetAll(ArticleGetAllEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await getAll(NoParams());

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onAddArticle(AddArticleEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await addArticle(AddArticleParams(article: event.article));

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onRemoveArticle(RemoveArticleEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await removeArticle(
      RemoveArticleParams(index: event.index),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onToogleArticleDoneState(
    ToogleArticleDoneStateEvent event,
    Emitter emit,
  ) async {
    emit(ArticleLoading());
    final result = await toogleArticleDoneState(
      ToogleArticleDoneStateParams(index: event.index),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onClear(ClearEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await clear(ClearParams(allArticle: event.allArticle));

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onArticleImport(ArticleImportEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await articleImport(ArticleImportParams(json: event.json));

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onUpdateArticle(UpdateArticleEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await updateArticle(UpdateArticleParams(article: event.article, label: event.label, quantity: event.quantity));

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

}
