import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shopping_list/core/theme/palette.dart';

/// Builds the app theme from a [Palette].
///
/// Widgets keep reading the Material colour scheme; it is filled so that
/// `primary` is the brand indigo, `secondary` the accent, `tertiary` the
/// "done" colour, `outline` the muted text and `surfaceContainer` the cards.
/// Titles use Bricolage Grotesque, the rest Figtree (both bundled).
ThemeData buildTheme(Ambiance ambiance, Brightness brightness) {
  final p = Palette.of(ambiance, brightness);
  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.brand,
    onPrimary: brightness == Brightness.light ? Colors.white : p.ground,
    primaryContainer: p.brandSoft,
    onPrimaryContainer: p.ink,
    secondary: p.accent,
    onSecondary: p.onAccent,
    secondaryContainer: p.brandSoft,
    onSecondaryContainer: p.ink,
    tertiary: p.done,
    onTertiary: brightness == Brightness.light ? Colors.white : p.ground,
    error: p.danger,
    onError: brightness == Brightness.light ? Colors.white : p.ground,
    surface: p.ground,
    onSurface: p.ink,
    onSurfaceVariant: p.muted,
    surfaceContainerLowest: p.ground,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: p.surface,
    surfaceContainerHighest: p.line,
    outline: p.muted,
    outlineVariant: p.line,
    inverseSurface: p.ink,
    onInverseSurface: p.ground,
    surfaceTint: Colors.transparent,
  );

  final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(p.radius));
  final roundedSmall = RoundedRectangleBorder(borderRadius: BorderRadius.circular(p.radius * 0.6));
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: AppFonts.text,
  );

  return base.copyWith(
    scaffoldBackgroundColor: p.ground,
    canvasColor: p.ground,
    splashFactory: InkSparkle.splashFactory,
    textTheme: _textTheme(base.textTheme, p),
    appBarTheme: AppBarTheme(
      backgroundColor: p.ground,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.titles,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      shape: rounded,
      clipBehavior: Clip.antiAlias,
    ),
    listTileTheme: ListTileThemeData(iconColor: p.muted, textColor: p.ink, shape: rounded),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: p.muted, width: 2),
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.done : null),
      checkColor: WidgetStatePropertyAll(scheme.onTertiary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        minimumSize: const Size(48, 48),
        shape: roundedSmall,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        side: BorderSide(color: p.line, width: 1.5),
        minimumSize: const Size(48, 48),
        shape: roundedSmall,
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: p.brand)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.accent,
      foregroundColor: p.onAccent,
      elevation: 0,
      highlightElevation: 0,
      shape: p.radius >= 20 ? const StadiumBorder() : roundedSmall,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      hintStyle: TextStyle(color: p.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(p.radius * 0.6),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(p.radius * 0.6),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(p.radius * 0.6),
        borderSide: BorderSide(color: p.brand, width: 2),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.ground,
      surfaceTintColor: Colors.transparent,
      shape: rounded,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.ground,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: p.ground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(p.radius))),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: roundedSmall,
      elevation: 2,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.ink,
      contentTextStyle: TextStyle(color: p.ground),
      actionTextColor: brightness == Brightness.light
          ? Palette.of(ambiance, Brightness.dark).accent
          : p.accent,
      behavior: SnackBarBehavior.floating,
      shape: roundedSmall,
    ),
    dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.done, linearTrackColor: p.line),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.onAccent : p.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.accent : p.line,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: p.ground,
        foregroundColor: p.ink,
        selectedBackgroundColor: p.brandSoft,
        selectedForegroundColor: p.brand,
        side: BorderSide(color: p.line),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(p.radius * 0.55)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.ground,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.brandSoft,
      elevation: 0,
    ),
    badgeTheme: BadgeThemeData(textColor: p.ink),
  );
}

/// The app's typefaces, bundled so the app needs no network.
abstract final class AppFonts {
  /// Display, headline and large titles: a grotesque with character.
  static const titles = 'Bricolage Grotesque';

  /// Everything else: round and easy to read at small sizes.
  static const text = 'Figtree';
}

/// [AppFonts.titles] for display, headline and large title styles, a little
/// tighter; [AppFonts.text] for the rest.
TextTheme _textTheme(TextTheme base, Palette p) {
  TextStyle? title(TextStyle? s) => s?.copyWith(
    fontFamily: AppFonts.titles,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: p.ink,
  );
  TextStyle? body(TextStyle? s) => s?.copyWith(color: p.ink);
  return base.copyWith(
    displayLarge: title(base.displayLarge),
    displayMedium: title(base.displayMedium),
    displaySmall: title(base.displaySmall),
    headlineLarge: title(base.headlineLarge),
    headlineMedium: title(base.headlineMedium),
    headlineSmall: title(base.headlineSmall),
    titleLarge: title(base.titleLarge),
    titleMedium: body(base.titleMedium),
    titleSmall: body(base.titleSmall),
    bodyLarge: body(base.bodyLarge),
    bodyMedium: body(base.bodyMedium),
    bodySmall: base.bodySmall?.copyWith(color: p.muted),
    labelLarge: body(base.labelLarge),
    labelMedium: body(base.labelMedium),
    labelSmall: base.labelSmall?.copyWith(color: p.muted),
  );
}

/// The shadcn theme for the same [Palette]: shadcn components and the
/// Material widgets the app keeps share one set of colours.
ShadThemeData buildShadTheme(Ambiance ambiance, Brightness brightness) {
  final p = Palette.of(ambiance, brightness);
  final onDark = brightness == Brightness.light ? Colors.white : p.ground;
  return ShadThemeData(
    brightness: brightness,
    textTheme: ShadTextTheme(family: AppFonts.text),
    radius: BorderRadius.circular(p.radius * 0.6),
    colorScheme: ShadColorScheme(
      background: p.ground,
      foreground: p.ink,
      card: p.surface,
      cardForeground: p.ink,
      popover: p.ground,
      popoverForeground: p.ink,
      primary: p.accent,
      primaryForeground: p.onAccent,
      secondary: p.surface,
      secondaryForeground: p.ink,
      muted: p.surface,
      mutedForeground: p.muted,
      accent: p.brandSoft,
      accentForeground: p.ink,
      destructive: p.danger,
      destructiveForeground: onDark,
      border: p.line,
      input: p.line,
      ring: p.brand,
      selection: p.brandSoft,
    ),
  );
}
