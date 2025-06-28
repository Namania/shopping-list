part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategorySuccess extends CategoryState {
  final List<CategoryModel> categories;

  const CategorySuccess({required this.categories});
}

final class CategoryFailure extends CategoryState {
  final String message;

  const CategoryFailure({required this.message});
}

class CategoryLoading extends CategoryState {}
