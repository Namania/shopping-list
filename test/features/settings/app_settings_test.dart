import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/features/settings/app_settings.dart';

void main() {
  test('round-trips through its map', () {
    const settings = AppSettings(
      themeMode: ThemeMode.light,
      startRoute: StartRoute.cards,
      uncategorizedFirst: false,
      calculatorEnabled: true,
    );
    expect(AppSettings.fromMap(settings.toMap()), settings);
  });

  test('reads the backup format of versions <= 1.3', () {
    final settings = AppSettings.fromLegacyMap({'theme': 2, 'route': 2, 'calculator': 1, 'category': 0});
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.startRoute, StartRoute.cards);
    expect(settings.calculatorEnabled, isFalse);
    expect(settings.uncategorizedFirst, isTrue);
  });

  test('falls back to the defaults on unknown legacy values', () {
    final settings = AppSettings.fromLegacyMap({
      'theme': 42,
      'route': -1,
      'calculator': 'yes',
      'category': null,
    });
    expect(settings, const AppSettings());
  });
}
