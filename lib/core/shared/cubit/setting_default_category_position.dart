import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingDefaultCategoryPosition extends HydratedCubit<AvailableState> {
  SettingDefaultCategoryPosition() : super(AvailableState.first);

  void toggleValue() {
    switch (state) {
      case AvailableState.first:
        emit(AvailableState.last);
      case AvailableState.last:
        emit(AvailableState.first);
    }
  }

  bool getValue() {
    switch (state) {
      case AvailableState.first:
        return true;
      case AvailableState.last:
        return false;
    }
  }

  void selectValue(AvailableState value) {
    emit(value);
  }

  @override
  AvailableState? fromJson(Map<String, dynamic> json) {
    return AvailableState.values[json['setting_default_category_position'] as int];
  }

  @override
  Map<String, dynamic>? toJson(AvailableState state) {
    return {'setting_default_category_position': state.index};
  }
}

enum AvailableState {
  first,
  last,
}
