import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/core/theme/palette.dart';
import 'package:shopping_list/features/settings/app_settings.dart';

void main() {
  test('round-trips through its map', () {
    const settings = AppSettings(
      themeMode: ThemeMode.light,
      ambiance: Ambiance.fresh,
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

  test('keeps the language, and reads the "lang" of older backups', () {
    const settings = AppSettings(languageCode: 'en');
    expect(AppSettings.fromMap(settings.toMap()), settings);
    expect(AppSettings.fromMap({'lang': 'fr'}).languageCode, 'fr');
    expect(AppSettings.fromLegacyMap({'lang': 'en'}).languageCode, 'en');
    expect(AppSettings.fromMap({}).languageCode, isNull);
    expect(const AppSettings(languageCode: 'fr').copyWith(languageCode: null).languageCode, isNull);
  });

  test('reads the locale easy_localization saved', () {
    expect(AppSettings.language('fr'), 'fr');
    expect(AppSettings.language('fr_FR'), 'fr');
    expect(AppSettings.language('en-US'), 'en');
    expect(AppSettings.language('de'), isNull);
    expect(AppSettings.language(null), isNull);
  });
}
