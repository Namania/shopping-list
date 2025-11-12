import 'package:hydrated_bloc/hydrated_bloc.dart';

class MigrateArticleToMultipleListCubit extends HydratedCubit<bool> {
  MigrateArticleToMultipleListCubit() : super(false);

  void set(bool value) {
    emit(value);
  }

  bool hasNotBeenPlay() {
    return !state;
  }

  @override
  bool? fromJson(Map<String, dynamic> json) {
    return json['migrate_article_to_multiple_list'] as bool;
  }

  @override
  Map<String, dynamic>? toJson(bool state) {
    return {'migrate_article_to_multiple_list': state};
  }
}
