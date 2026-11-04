import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/core/theme/app_theme.dart';
import 'package:shopping_list/core/theme/palette.dart';

/// WCAG contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  double luminance(Color c) {
    double channel(double v) => v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  }

  final (l1, l2) = (luminance(a), luminance(b));
  return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);
}

void main() {
  for (final ambiance in Ambiance.values) {
    for (final brightness in Brightness.values) {
      final p = Palette.of(ambiance, brightness);
      final name = '${ambiance.name} ${brightness.name}';

      test('$name: text passes 4.5:1 on the ground and on cards', () {
        for (final background in [p.ground, p.surface]) {
          expect(contrast(p.ink, background), greaterThanOrEqualTo(4.5));
          expect(contrast(p.muted, background), greaterThanOrEqualTo(4.5));
          expect(contrast(p.brand, background), greaterThanOrEqualTo(4.5));
        }
      });

      test('$name: buttons and checked items are readable', () {
        expect(contrast(p.onAccent, p.accent), greaterThanOrEqualTo(4.5));
        expect(contrast(p.done, p.ground), greaterThanOrEqualTo(3));
        expect(contrast(p.accent, p.ground), greaterThanOrEqualTo(3));
      });

      test('$name: the theme builds', () {
        final theme = buildTheme(ambiance, brightness);
        expect(theme.colorScheme.primary, p.brand);
        expect(theme.scaffoldBackgroundColor, p.ground);
      });
    }
  }
}
