import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// A card that can be swiped away in either direction. The swipe is only
/// completed when [confirm] returns `true`. With [card] off, the row is
/// drawn bare, for rows grouped inside a card of their own.
class SwipeToDelete extends StatelessWidget {
  final String id;
  final Future<bool> Function() confirm;
  final VoidCallback onDeleted;
  final Widget child;
  final bool card;

  const SwipeToDelete({
    super.key,
    required this.id,
    required this.confirm,
    required this.onDeleted,
    required this.child,
    this.card = true,
  });

  @override
  Widget build(BuildContext context) {
    final dismissible = Dismissible(
      key: ValueKey('swipe-$id'),
      confirmDismiss: (_) => confirm(),
      onDismissed: (_) => onDeleted(),
      background: const _DeleteBackground(alignment: MainAxisAlignment.start),
      secondaryBackground: const _DeleteBackground(alignment: MainAxisAlignment.end),
      child: child,
    );
    return card ? Card(child: dismissible) : dismissible;
  }
}

class _DeleteBackground extends StatelessWidget {
  final MainAxisAlignment alignment;

  const _DeleteBackground({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      context.l10n.commonDelete,
      style: TextTheme.of(context).bodyLarge!.apply(color: Theme.of(context).colorScheme.onError),
    );
    final icon = Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.onError);
    return Container(
      color: Theme.of(context).colorScheme.error,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: alignment,
        spacing: 5,
        children: alignment == MainAxisAlignment.start ? [icon, label] : [label, icon],
      ),
    );
  }
}
