import 'package:flutter/material.dart';

TextTheme createTextTheme(
    BuildContext context, String bodyFontString, String displayFontString) {
  TextTheme baseTextTheme = Theme.of(context).textTheme.apply(fontFamily: 'Montserrat');
  TextTheme textTheme = baseTextTheme.copyWith(
    bodyLarge: baseTextTheme.bodyLarge,
    bodyMedium: baseTextTheme.bodyMedium,
    bodySmall: baseTextTheme.bodySmall,
    labelLarge: baseTextTheme.labelLarge,
    labelMedium: baseTextTheme.labelMedium,
    labelSmall: baseTextTheme.labelSmall,
  );
  return textTheme;
}
