import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingEnableCalculator extends HydratedCubit<AvailableCalculatorState> {
  SettingEnableCalculator() : super(AvailableCalculatorState.disable);

  void toggleValue() {
    switch (state) {
      case AvailableCalculatorState.enable:
        emit(AvailableCalculatorState.disable);
      case AvailableCalculatorState.disable:
        emit(AvailableCalculatorState.enable);
    }
  }

  bool isEnabled() {
    switch (state) {
      case AvailableCalculatorState.enable:
        return true;
      case AvailableCalculatorState.disable:
        return false;
    }
  }

  void selectValue(AvailableCalculatorState value) {
    emit(value);
  }

  @override
  AvailableCalculatorState? fromJson(Map<String, dynamic> json) {
    return AvailableCalculatorState.values[json['setting_enable_calculator'] as int];
  }

  @override
  Map<String, dynamic>? toJson(AvailableCalculatorState state) {
    return {'setting_enable_calculator': state.index};
  }
}

enum AvailableCalculatorState {
  enable,
  disable,
}
