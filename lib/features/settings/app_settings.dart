import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/theme/palette.dart';

/// Screen shown when the app starts.
enum StartRoute {
  home('/'),
  lists('/lists'),
  cards('/cards');

  final String path;
  const StartRoute(this.path);
}

class AppSettings extends Equatable {
  final ThemeMode themeMode;
  final Ambiance ambiance;
  final StartRoute startRoute;

  /// Show uncategorized articles before the categorized ones.
  final bool uncategorizedFirst;
  final bool calculatorEnabled;

  /// `fr` or `en`; `null` follows the phone's language.
  final String? languageCode;

  /// The languages the app is translated into.
  static const languages = ['fr', 'en'];

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.ambiance = Ambiance.warm,
    this.startRoute = StartRoute.home,
    this.uncategorizedFirst = true,
    this.calculatorEnabled = false,
    this.languageCode,
  });

  static const _keep = Object();

  /// Pass `languageCode: null` to follow the phone's language again.
  AppSettings copyWith({
    ThemeMode? themeMode,
    Ambiance? ambiance,
    StartRoute? startRoute,
    bool? uncategorizedFirst,
    bool? calculatorEnabled,
    Object? languageCode = _keep,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    ambiance: ambiance ?? this.ambiance,
    startRoute: startRoute ?? this.startRoute,
    uncategorizedFirst: uncategorizedFirst ?? this.uncategorizedFirst,
    calculatorEnabled: calculatorEnabled ?? this.calculatorEnabled,
    languageCode: identical(languageCode, _keep) ? this.languageCode : languageCode as String?,
  );

  Map<String, dynamic> toMap() => {
    'theme': themeMode.name,
    'ambiance': ambiance.name,
    'startRoute': startRoute.name,
    'uncategorizedFirst': uncategorizedFirst,
    'calculatorEnabled': calculatorEnabled,
    'language': languageCode,
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    themeMode: _byName(ThemeMode.values, map['theme'], ThemeMode.system),
    ambiance: _byName(Ambiance.values, map['ambiance'], Ambiance.warm),
    startRoute: _byName(StartRoute.values, map['startRoute'], StartRoute.home),
    uncategorizedFirst: map['uncategorizedFirst'] as bool? ?? true,
    calculatorEnabled: map['calculatorEnabled'] as bool? ?? false,
    // Backups made before the language moved into the settings call it "lang".
    languageCode: language(map['language'] ?? map['lang']),
  );

  /// Backup format of versions <= 1.3.x, where each setting was the index of
  /// an enum in the "cubits" object. Unknown values fall back to the defaults.
  factory AppSettings.fromLegacyMap(Map<String, dynamic> map) => AppSettings(
    themeMode: _byIndex(ThemeMode.values, map['theme'], ThemeMode.system),
    startRoute: _byIndex(StartRoute.values, map['route'], StartRoute.home),
    // 0 = enabled, 1 = disabled
    calculatorEnabled: map['calculator'] == 0,
    // 0 = first, 1 = last
    uncategorizedFirst: map['category'] != 1,
    languageCode: language(map['lang']),
  );

  /// A supported language code read from a stored locale ("fr", "fr_FR",
  /// "en-US"), `null` for anything else.
  static String? language(Object? stored) {
    if (stored is! String || stored.length < 2) return null;
    final code = stored.substring(0, 2).toLowerCase();
    return languages.contains(code) ? code : null;
  }

  static T _byIndex<T>(List<T> values, Object? index, T fallback) =>
      index is int && index >= 0 && index < values.length ? values[index] : fallback;

  static T _byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
      values.where((v) => v.name == name).firstOrNull ?? fallback;

  @override
  List<Object?> get props => [
    themeMode,
    ambiance,
    startRoute,
    uncategorizedFirst,
    calculatorEnabled,
    languageCode,
  ];
}
