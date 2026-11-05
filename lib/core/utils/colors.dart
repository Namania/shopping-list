import 'package:flutter/material.dart';

/// The colour a card or a category gets when it has none: the logo's violet.
const fallbackItemColor = Color(0xFF545A92);

/// A stored colour as one that can be seen: a missing or fully transparent
/// one (cards of older versions, hand-written files) becomes [fallback]; a
/// translucent one loses its transparency.
Color opaqueColor(int? value, {Color fallback = fallbackItemColor}) {
  if (value == null || value >>> 24 == 0) return fallback;
  return Color(value | 0xFF000000);
}

/// Contrast ratio between two colours, 1 (same) to 21 (black on white).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

/// Whether [color] blends into what it is drawn on: the page or a card of
/// the current theme (a white card on the light theme, a black one on the
/// dark theme).
bool blendsIn(BuildContext context, Color color) {
  final theme = Theme.of(context);
  final grounds = [
    theme.scaffoldBackgroundColor,
    theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow,
  ];
  return grounds.any((ground) => contrastRatio(color, ground) < 1.35);
}

/// A thin outline that keeps a coloured shape visible when it [blendsIn];
/// `null` otherwise.
Border? edgeFor(BuildContext context, Color color, {double width = 1}) =>
    blendsIn(context, color) ? Border.all(color: Theme.of(context).colorScheme.outline, width: width) : null;

/// [color] for an icon or a text, or the theme's muted ink when it would
/// blend in.
Color visibleColor(BuildContext context, Color color) =>
    blendsIn(context, color) ? Theme.of(context).colorScheme.onSurfaceVariant : color;
