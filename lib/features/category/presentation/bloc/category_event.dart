part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class CategoryGetAllEvent extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final CategoryModel category;

  const AddCategoryEvent({required this.category});
}

class RemoveCategoryEvent extends CategoryEvent {
  final int index;

  const RemoveCategoryEvent({required this.index});
}

class UpdateCategoryEvent extends CategoryEvent {
  final CategoryModel category;
  final String label;
  final Color color;

  const UpdateCategoryEvent({
    required this.category,
    required this.label,
    required this.color,
  });
}

class CategoryImportEvent extends CategoryEvent {
  final String json;

  const CategoryImportEvent({required this.json});
}

class ClearCategoryEvent extends CategoryEvent {}

class RerangeCategoryEvent extends CategoryEvent {
  final int oldIndex;
  final int newIndex;

  const RerangeCategoryEvent({
    required this.oldIndex,
    required this.newIndex,
  });
}
