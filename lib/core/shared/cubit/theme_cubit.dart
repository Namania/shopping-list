import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  Brightness get systemBrightness =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  void toggleThemeMode() {
    switch (state) {
      case ThemeMode.system:
        if (systemBrightness == Brightness.light) {
          emit(ThemeMode.dark);
        } else {
          emit(ThemeMode.light);
        }

      case ThemeMode.light:
        emit(ThemeMode.dark);

      case ThemeMode.dark:
        emit(ThemeMode.light);
    }
  }

  void selectThemeMode(ThemeMode themeMode) {
    emit(themeMode);
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    return ThemeMode.values[json['theme_mode'] as int];
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'theme_mode': state.index};
  }
}
