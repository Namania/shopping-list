import 'package:hydrated_bloc/hydrated_bloc.dart';

class MigrateCardAddIdCubit extends HydratedCubit<bool> {
  MigrateCardAddIdCubit() : super(false);

  void set(bool value) {
    emit(value);
  }

  bool hasNotBeenPlay() {
    return !state;
  }

  @override
  bool? fromJson(Map<String, dynamic> json) {
    return json['migrate_card_add_id'] as bool;
  }

  @override
  Map<String, dynamic>? toJson(bool state) {
    return {'migrate_card_add_id': state};
  }
}
