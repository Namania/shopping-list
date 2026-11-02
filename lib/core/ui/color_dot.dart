import 'package:flutter/material.dart';

/// The small coloured dot that marks a category or a card.
class ColorDot extends StatelessWidget {
  final Color color;

  const ColorDot(this.color, {super.key});

  @override
  Widget build(BuildContext context) =>
      Badge(padding: const EdgeInsets.all(3), backgroundColor: color, label: const SizedBox(height: 10));
}
