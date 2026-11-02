import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
  final StartRoute startRoute;

  /// Show uncategorized articles before the categorized ones.
  final bool uncategorizedFirst;
  final bool calculatorEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.startRoute = StartRoute.home,
    this.uncategorizedFirst = true,
    this.calculatorEnabled = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    StartRoute? startRoute,
    bool? uncategorizedFirst,
    bool? calculatorEnabled,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    startRoute: startRoute ?? this.startRoute,
    uncategorizedFirst: uncategorizedFirst ?? this.uncategorizedFirst,
    calculatorEnabled: calculatorEnabled ?? this.calculatorEnabled,
  );

  Map<String, dynamic> toMap() => {
    'theme': themeMode.name,
    'startRoute': startRoute.name,
    'uncategorizedFirst': uncategorizedFirst,
    'calculatorEnabled': calculatorEnabled,
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    themeMode: ThemeMode.values.byName(map['theme'] as String? ?? 'system'),
    startRoute: StartRoute.values.byName(map['startRoute'] as String? ?? 'home'),
    uncategorizedFirst: map['uncategorizedFirst'] as bool? ?? true,
    calculatorEnabled: map['calculatorEnabled'] as bool? ?? false,
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
  );

  static T _byIndex<T>(List<T> values, Object? index, T fallback) =>
      index is int && index >= 0 && index < values.length ? values[index] : fallback;

  @override
  List<Object?> get props => [themeMode, startRoute, uncategorizedFirst, calculatorEnabled];
}
