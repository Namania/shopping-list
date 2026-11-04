import 'package:flutter/material.dart';

/// A ring that fills as articles go into the cart, with "done/total" in the
/// middle; a check once everything is in.
class ProgressRing extends StatelessWidget {
  final int done;
  final int total;
  final double size;

  const ProgressRing({super.key, required this.done, required this.total, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final complete = total > 0 && done == total;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: total == 0 ? 0 : done / total),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: size / 9,
                strokeCap: StrokeCap.round,
                color: colors.tertiary,
                backgroundColor: colors.outlineVariant,
              ),
            ),
          ),
          if (complete)
            Icon(Icons.check_rounded, size: size * 0.5, color: colors.tertiary)
          else
            Text(
              '$done/$total',
              // Sized to the ring, which does not grow with the font size.
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: size * (total >= 10 ? 0.24 : 0.28),
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}
