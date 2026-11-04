import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The small pencil that opens the edit form of a tile.
class EditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    tooltip: context.l10n.commonEdit,
    iconSize: 20,
    visualDensity: VisualDensity.compact,
    icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.outline),
  );
}
