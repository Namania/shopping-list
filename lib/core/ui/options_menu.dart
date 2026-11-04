import 'package:flutter/material.dart';

class MenuOption<T> {
  final T value;
  final IconData icon;
  final String label;

  const MenuOption(this.value, {required this.icon, required this.label});
}

/// The "⋮" menu of an app bar.
class OptionsMenu<T> extends StatelessWidget {
  final List<MenuOption<T>> options;
  final ValueChanged<T> onSelected;

  const OptionsMenu({super.key, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<T>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surfaceContainer,
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<T>(
            value: option.value,
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Row(
              spacing: 10,
              children: [
                Icon(option.icon, size: 20, color: theme.iconTheme.color),
                Text(option.label, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }
}
