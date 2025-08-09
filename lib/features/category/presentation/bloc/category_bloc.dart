import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/usecase/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/domain/usecases/add_category_from_map.dart';
import 'package:shopping_list/features/category/domain/usecases/category_import.dart';
import 'package:shopping_list/features/category/domain/usecases/clear.dart';
import 'package:shopping_list/features/category/domain/usecases/get_all_category.dart';
import 'package:shopping_list/features/category/domain/usecases/remove_category_from_map.dart';
import 'package:shopping_list/features/category/domain/usecases/rerange.dart';
import 'package:shopping_list/features/category/domain/usecases/update_category.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategory getAll;
  final AddCategory addCategory;
  final RemoveCategory removeCategory;
  final UpdateCategory updateCategory;
  final CategoryImport categoryImport;
  final ClearCategory clearCategory;
  final RerangeCategory rerangeCategory;

  CategoryBloc({
    required this.getAll,
    required this.addCategory,
    required this.removeCategory,
    required this.updateCategory,
    required this.categoryImport,
    required this.clearCategory,
    required this.rerangeCategory,
  }) : super(CategoryInitial()) {
    on<CategoryEvent>((event, emit) {
      emit(CategoryLoading());
    });
    on<CategoryGetAllEvent>((event, emit) => _onGetAll(event, emit));
    on<AddCategoryEvent>((event, emit) => _onAddCategory(event, emit));
    on<RemoveCategoryEvent>((event, emit) => _onRemoveCategory(event, emit));
    on<UpdateCategoryEvent>((event, emit) => _onUpdateCategory(event, emit));
    on<CategoryImportEvent>((event, emit) => _onCategoryImport(event, emit));
    on<ClearCategoryEvent>((event, emit) => _onClearCategory(event, emit));
    on<RerangeCategoryEvent>((event, emit) => _onRerangeCategory(event, emit));
    add(CategoryGetAllEvent());
  }

  Future<void> _onGetAll(CategoryGetAllEvent event, Emitter emit) async {
    emit(CategoryLoading());
    final result = await getAll(NoParams());

    result.fold(
      (l) => emit(CategoryFailure(message: l.message)),
      (r) => emit(CategorySuccess(categories: r)),
    );
  }

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter emit) async {
    emit(CategoryLoading());
    final result = await addCategory(
      AddCategoryParams(category: event.category),
    );

    result.fold(
      (l) => emit(CategoryFailure(message: l.message)),
      (r) => emit(CategorySuccess(categories: r)),
    );
  }

  Future<void> _onRemoveCategory(
    RemoveCategoryEvent event,
    Emitter emit,
  ) async {
    emit(CategoryLoading());
    final result = await removeCategory(
      RemoveCategoryParams(index: event.index),
    );

    result.fold(
      (l) => emit(CategoryFailure(message: l.message)),
      (r) => emit(CategorySuccess(categories: r)),
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter emit,
  ) async {
    emit(CategoryLoading());
    final result = await updateCategory(
      UpdateCategoryParams(
        category: event.category,
        label: event.label,
        color: event.color,
      ),
    );

    result.fold(
      (l) => emit(CategoryFailure(message: l.message)),
      (r) => emit(CategorySuccess(categories: r)),
    );
  }

  Future<void> _onClearCategory(ClearCategoryEvent event, Emitter emit) async {
    emit(CategoryLoading());
    final result = await clearCategory(NoParams());

    result.fold(
      (l) => emit(CategoryFailure(message: l.message)),
      (r) => emit(CategorySuccess(categories: r)),
    );
  }

  Future<void> _onCategoryImport(CategoryImportEvent event, Emitter emit) async {
    emit(CategoryLoading());
    final result = await categoryImport(CategoryImportParams(json: event.json));

    result.fold(
      (l) => emit(CategoryFailure(message: l.message)),
      (r) => emit(CategorySuccess(categories: r)),
    );
  }

  Future<void> _onRerangeCategory(RerangeCategoryEvent event, Emitter emit) async {
    emit(CategoryLoading());
    final result = await rerangeCategory(
      RerangeCategoryParams(oldIndex: event.oldIndex, newIndex: event.newIndex),
    );

    result.fold(
      (l) => emit(CategoryFailure(message: l.message)),
      (r) => emit(CategorySuccess(categories: r)),
    );
  }

  List<CategoryModel> getAllCategory() {
    if (state is CategorySuccess) {
      return (state as CategorySuccess).categories.toList();
    }
    return [];
  }
}
