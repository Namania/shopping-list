import 'package:bloc/bloc.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/usecases/add_article_from_map.dart';
import 'package:shopping_list/features/article/domain/usecases/add_list.dart';
import 'package:shopping_list/features/article/domain/usecases/article_import.dart';
import 'package:shopping_list/features/article/domain/usecases/migrate_article_to_multiple_list.dart';
import 'package:shopping_list/features/article/domain/usecases/remove_article_from_map.dart';
import 'package:shopping_list/features/article/domain/usecases/clear.dart';
import 'package:shopping_list/features/article/domain/usecases/get_all.dart';
import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/article/domain/usecases/remove_list.dart';
import 'package:shopping_list/features/article/domain/usecases/rerange_article.dart';
import 'package:shopping_list/features/article/domain/usecases/toogle_article_done_state.dart';
import 'package:shopping_list/features/article/domain/usecases/update_article.dart';
import 'package:shopping_list/features/article/domain/usecases/update_article_list.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';

part 'article_event.dart';
part 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final GetAll getAll;
  final AddArticle addArticle;
  final AddList addList;
  final UpdateArticle updateArticle;
  final UpdateList updateList;
  final RemoveArticle removeArticle;
  final RemoveList removeList;
  final ToogleArticleDoneState toogleArticleDoneState;
  final Clear clear;
  final ArticleImport articleImport;
  final RerangeArticle rerangeArticle;
  final MigrateArticleToMultipleList migrateToMultipleList;

  ArticleBloc({
    required this.getAll,
    required this.addArticle,
    required this.addList,
    required this.updateArticle,
    required this.updateList,
    required this.removeArticle,
    required this.removeList,
    required this.toogleArticleDoneState,
    required this.clear,
    required this.articleImport,
    required this.migrateToMultipleList,
    required this.rerangeArticle,
  }) : super(ArticleInitial()) {
    on<ArticleEvent>((event, emit) {
      emit(ArticleLoading());
    });
    on<ArticleGetAllEvent>((event, emit) => _onGetAll(event, emit));
    on<AddArticleEvent>((event, emit) => _onAddArticle(event, emit));
    on<AddListEvent>((event, emit) => _onAddList(event, emit));
    on<UpdateArticleEvent>((event, emit) => _onUpdateArticle(event, emit));
    on<UpdateListEvent>((event, emit) => _onUpdateList(event, emit));
    on<RemoveArticleEvent>((event, emit) => _onRemoveArticle(event, emit));
    on<RemoveListEvent>((event, emit) => _onRemoveList(event, emit));
    on<ClearEvent>((event, emit) => _onClear(event, emit));
    on<ToogleArticleDoneStateEvent>(
      (event, emit) => _onToogleArticleDoneState(event, emit),
    );
    on<ArticleImportEvent>((event, emit) => _onArticleImport(event, emit));
    on<ArticleMigrateToMultipleListEvent>(
      (event, emit) => _onMigrateArticleToMultipleList(event, emit),
    );
    on<RerangeArticleEvent>((event, emit) => _onRerangeArticle(event, emit));
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
    final result = await addArticle(
      AddArticleParams(id: event.id, article: event.article),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onAddList(AddListEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await addList(
      AddListParams(articleList: event.articleList),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onRemoveArticle(RemoveArticleEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await removeArticle(
      RemoveArticleParams(id: event.id, article: event.article),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onRemoveList(RemoveListEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await removeList(
      RemoveListParams(articleList: event.articleList),
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
      ToogleArticleDoneStateParams(id: event.id, article: event.article),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onClear(ClearEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await clear(
      ClearParams(id: event.id, allArticle: event.allArticle),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onArticleImport(ArticleImportEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await articleImport(
      ArticleImportParams(
        json: event.json,
        defaultCategory: event.defaultCategory,
      ),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onUpdateArticle(UpdateArticleEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await updateArticle(
      UpdateArticleParams(
        id: event.id,
        article: event.article,
        label: event.label,
        category: event.category,
      ),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onUpdateList(UpdateListEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await updateList(
      UpdateListParams(
        articleList: event.articleList,
        label: event.label,
        card: event.card,
      ),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  Future<void> _onRerangeArticle(RerangeArticleEvent event, Emitter emit) async {
    emit(ArticleLoading());
    final result = await rerangeArticle(
      RerangeArticleParams(oldIndex: event.oldIndex, newIndex: event.newIndex),
    );

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }

  List<ArticleListModel> getAllArticle() {
    if (state is ArticleSuccess) {
      return (state as ArticleSuccess).articles.toList();
    }
    return [];
  }

  Future<void> _onMigrateArticleToMultipleList(
    ArticleMigrateToMultipleListEvent event,
    Emitter emit,
  ) async {
    emit(ArticleLoading());
    final result = await migrateToMultipleList(NoParams());

    result.fold(
      (l) => emit(ArticleFailure(message: l.message)),
      (r) => emit(ArticleSuccess(articles: r)),
    );
  }
}
