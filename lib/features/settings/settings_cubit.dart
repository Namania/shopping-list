import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/theme/palette.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';

class SettingsCubit extends Cubit<AppSettings> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository, AppSettings initial) : super(initial);

  static Future<SettingsCubit> load(SettingsRepository repository) async =>
      SettingsCubit(repository, await repository.load());

  Future<void> replace(AppSettings settings) async {
    await _repository.save(settings);
    emit(settings);
  }

  Future<void> setThemeMode(ThemeMode mode) => replace(state.copyWith(themeMode: mode));

  /// `null` follows the phone's language.
  Future<void> setLanguage(String? code) => replace(state.copyWith(languageCode: code));

  Future<void> setAmbiance(Ambiance ambiance) => replace(state.copyWith(ambiance: ambiance));

  Future<void> setStartRoute(StartRoute route) => replace(state.copyWith(startRoute: route));

  Future<void> setUncategorizedFirst(bool value) => replace(state.copyWith(uncategorizedFirst: value));

  Future<void> setCalculatorEnabled(bool value) => replace(state.copyWith(calculatorEnabled: value));
}
