import 'package:flutter/material.dart';
import 'package:shopping_list/l10n/app_localizations.dart';

/// The look of the app, chosen in the settings: a full palette, in a light
/// and a dark version.
enum Ambiance {
  /// Cream, sand and burnt orange.
  warm,

  /// White, cool greys and indigo.
  fresh,

  /// Sage greens and bronze.
  forest,

  /// Sea blues and teal.
  ocean,

  /// Soft violets.
  lavender,

  /// Blush pinks and raspberry.
  rose;

  String label(AppLocalizations l10n) => switch (this) {
    warm => l10n.settingsAmbiancesWarm,
    fresh => l10n.settingsAmbiancesFresh,
    forest => l10n.settingsAmbiancesForest,
    ocean => l10n.settingsAmbiancesOcean,
    lavender => l10n.settingsAmbiancesLavender,
    rose => l10n.settingsAmbiancesRose,
  };
}

/// The few colours an ambiance is made of, for one brightness. Everything
/// else in the theme is derived from them.
class Palette {
  /// Page background.
  final Color ground;

  /// Cards, sheets, fields.
  final Color surface;

  /// Hairlines and progress tracks.
  final Color line;

  final Color ink;

  /// Secondary text and icons; passes 4.5:1 on [ground] and [surface].
  final Color muted;

  /// Selected items, links, icons.
  final Color brand;

  /// Soft brand tint behind selected items.
  final Color brandSoft;

  /// Main actions: add button, filled buttons, prices.
  final Color accent;
  final Color onAccent;

  /// Checked articles, progress.
  final Color done;

  final Color danger;

  /// Corner radius of cards and sheets. 20 and above also rounds the add
  /// button into a pill.
  final double radius;

  const Palette({
    required this.ground,
    required this.surface,
    required this.line,
    required this.ink,
    required this.muted,
    required this.brand,
    required this.brandSoft,
    required this.accent,
    required this.onAccent,
    required this.done,
    required this.danger,
    required this.radius,
  });

  static Palette of(Ambiance ambiance, Brightness brightness) {
    final (light, dark) = switch (ambiance) {
      Ambiance.warm => (warmLight, warmDark),
      Ambiance.fresh => (freshLight, freshDark),
      Ambiance.forest => (forestLight, forestDark),
      Ambiance.ocean => (oceanLight, oceanDark),
      Ambiance.lavender => (lavenderLight, lavenderDark),
      Ambiance.rose => (roseLight, roseDark),
    };
    return brightness == Brightness.light ? light : dark;
  }

  static const _dangerLight = Color(0xFFB3261E);
  static const _dangerDark = Color(0xFFF2B8B5);

  static const warmLight = Palette(
    ground: Color(0xFFFBF7F0),
    surface: Color(0xFFF3EBDF),
    line: Color(0xFFE6DACA),
    ink: Color(0xFF2B2420),
    muted: Color(0xFF6E6157),
    brand: Color(0xFFA3461A),
    brandSoft: Color(0xFFF6DDCB),
    accent: Color(0xFFC2531F),
    onAccent: Color(0xFFFFFFFF),
    done: Color(0xFF3F7A3A),
    danger: _dangerLight,
    radius: 22,
  );

  static const warmDark = Palette(
    ground: Color(0xFF1C1916),
    surface: Color(0xFF28221E),
    line: Color(0xFF3B342E),
    ink: Color(0xFFF3ECE3),
    muted: Color(0xFFB8AA9C),
    brand: Color(0xFFF2A983),
    brandSoft: Color(0xFF4A2F22),
    accent: Color(0xFFE88A5C),
    onAccent: Color(0xFF1C1916),
    done: Color(0xFF93C78B),
    danger: _dangerDark,
    radius: 22,
  );

  static const freshLight = Palette(
    ground: Color(0xFFFFFFFF),
    surface: Color(0xFFF3F4F9),
    line: Color(0xFFE3E5EF),
    ink: Color(0xFF15172A),
    muted: Color(0xFF5D6178),
    brand: Color(0xFF545A92),
    brandSoft: Color(0xFFE6E7F4),
    accent: Color(0xFF545A92),
    onAccent: Color(0xFFFFFFFF),
    done: Color(0xFF1A7A50),
    danger: _dangerLight,
    radius: 16,
  );

  static const freshDark = Palette(
    ground: Color(0xFF111219),
    surface: Color(0xFF1C1E29),
    line: Color(0xFF2D3040),
    ink: Color(0xFFECEDF5),
    muted: Color(0xFFA6AAC0),
    brand: Color(0xFFBCC0F2),
    brandSoft: Color(0xFF2C2F4A),
    accent: Color(0xFFBCC0F2),
    onAccent: Color(0xFF15172A),
    done: Color(0xFF72D1A0),
    danger: _dangerDark,
    radius: 16,
  );

  static const forestLight = Palette(
    ground: Color(0xFFF5F7F2),
    surface: Color(0xFFE8EEE3),
    line: Color(0xFFD3DDCB),
    ink: Color(0xFF1C261D),
    muted: Color(0xFF4F5D52),
    brand: Color(0xFF2E5E3E),
    brandSoft: Color(0xFFDCE8DD),
    accent: Color(0xFF8A5A1F),
    onAccent: Color(0xFFFFFFFF),
    done: Color(0xFF2F7A4B),
    danger: _dangerLight,
    radius: 20,
  );

  static const forestDark = Palette(
    ground: Color(0xFF141A15),
    surface: Color(0xFF1E2620),
    line: Color(0xFF2E3830),
    ink: Color(0xFFE9EFE6),
    muted: Color(0xFFA7B4A9),
    brand: Color(0xFFA7D3B2),
    brandSoft: Color(0xFF27382B),
    accent: Color(0xFFE0A867),
    onAccent: Color(0xFF141A15),
    done: Color(0xFF8FD1A2),
    danger: _dangerDark,
    radius: 20,
  );

  static const oceanLight = Palette(
    ground: Color(0xFFF4F8FB),
    surface: Color(0xFFE5EEF5),
    line: Color(0xFFD0DEEA),
    ink: Color(0xFF13222E),
    muted: Color(0xFF4E6070),
    brand: Color(0xFF1F5F8B),
    brandSoft: Color(0xFFDCE9F4),
    accent: Color(0xFF0F766E),
    onAccent: Color(0xFFFFFFFF),
    done: Color(0xFF2E7D4F),
    danger: _dangerLight,
    radius: 16,
  );

  static const oceanDark = Palette(
    ground: Color(0xFF0F1820),
    surface: Color(0xFF1A2530),
    line: Color(0xFF2A3846),
    ink: Color(0xFFE6EEF5),
    muted: Color(0xFFA3B4C3),
    brand: Color(0xFF9CCBEE),
    brandSoft: Color(0xFF22374A),
    accent: Color(0xFF5EC4B8),
    onAccent: Color(0xFF0F1820),
    done: Color(0xFF86D19E),
    danger: _dangerDark,
    radius: 16,
  );

  static const lavenderLight = Palette(
    ground: Color(0xFFF8F6FC),
    surface: Color(0xFFEEEAF7),
    line: Color(0xFFDDD6EE),
    ink: Color(0xFF221C33),
    muted: Color(0xFF5E5675),
    brand: Color(0xFF5B4A9E),
    brandSoft: Color(0xFFE6E0F5),
    accent: Color(0xFF6D3BD1),
    onAccent: Color(0xFFFFFFFF),
    done: Color(0xFF2F7A4B),
    danger: _dangerLight,
    radius: 20,
  );

  static const lavenderDark = Palette(
    ground: Color(0xFF15121E),
    surface: Color(0xFF211C2E),
    line: Color(0xFF332C45),
    ink: Color(0xFFEEEAF7),
    muted: Color(0xFFB1A8C8),
    brand: Color(0xFFC4B5FD),
    brandSoft: Color(0xFF2F2747),
    accent: Color(0xFFA78BFA),
    onAccent: Color(0xFF15121E),
    done: Color(0xFF8FD1A2),
    danger: _dangerDark,
    radius: 20,
  );

  static const roseLight = Palette(
    ground: Color(0xFFFCF6F7),
    surface: Color(0xFFF5E8EB),
    line: Color(0xFFEBD5DA),
    ink: Color(0xFF2E1C21),
    muted: Color(0xFF6B5359),
    brand: Color(0xFF8C2F4A),
    brandSoft: Color(0xFFF3DDE3),
    accent: Color(0xFFBE185D),
    onAccent: Color(0xFFFFFFFF),
    done: Color(0xFF2F7A4B),
    danger: _dangerLight,
    radius: 22,
  );

  static const roseDark = Palette(
    ground: Color(0xFF1C1316),
    surface: Color(0xFF2A1D21),
    line: Color(0xFF3E2C31),
    ink: Color(0xFFF5E8EB),
    muted: Color(0xFFC2A8AF),
    brand: Color(0xFFF4A6BF),
    brandSoft: Color(0xFF3D2730),
    accent: Color(0xFFF472B6),
    onAccent: Color(0xFF1C1316),
    done: Color(0xFF8FD1A2),
    danger: _dangerDark,
    radius: 22,
  );
}
