import 'package:flutter/material.dart';
import 'package:shopping_list/core/utils/colors.dart';

/// A rounded square in the category's colour with its initial.
class CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double size;

  const CategoryBadge({super.key, required this.label, required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final onColor = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final initial = label.trim().isEmpty ? '' : label.trim().characters.first.toUpperCase();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: edgeFor(context, color),
      ),
      child: Text(
        initial,
        // The initial is decoration: it scales with the badge, not the font size.
        textScaler: TextScaler.noScaling,
        style: TextStyle(color: onColor, fontWeight: FontWeight.w700, fontSize: size * 0.42),
      ),
    );
  }
}
