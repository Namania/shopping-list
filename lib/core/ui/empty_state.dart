import 'package:flutter/material.dart';

/// What a page shows when it has nothing to list yet.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const EmptyState({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        spacing: 16,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
            child: Icon(icon, size: 34, color: colors.primary),
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextTheme.of(context).bodyLarge!.copyWith(color: colors.outline),
          ),
        ],
      ),
    );
  }
}
