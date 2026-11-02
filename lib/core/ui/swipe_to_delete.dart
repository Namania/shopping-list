import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A card that can be swiped away in either direction. The swipe is only
/// completed when [confirm] returns `true`.
class SwipeToDelete extends StatelessWidget {
  final String id;
  final Future<bool> Function() confirm;
  final VoidCallback onDeleted;
  final Widget child;

  const SwipeToDelete({
    super.key,
    required this.id,
    required this.confirm,
    required this.onDeleted,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Dismissible(
      key: ValueKey('swipe-$id'),
      confirmDismiss: (_) => confirm(),
      onDismissed: (_) => onDeleted(),
      background: const _DeleteBackground(alignment: MainAxisAlignment.start),
      secondaryBackground: const _DeleteBackground(alignment: MainAxisAlignment.end),
      child: child,
    ),
  );
}

class _DeleteBackground extends StatelessWidget {
  final MainAxisAlignment alignment;

  const _DeleteBackground({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      context.tr('common.delete'),
      style: TextTheme.of(context).bodyLarge!.apply(color: Colors.white),
    );
    const icon = Icon(Icons.delete_rounded, color: Colors.white);
    return Container(
      color: const Color(0xff93000a),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: alignment,
        spacing: 5,
        children: alignment == MainAxisAlignment.start ? [icon, label] : [label, icon],
      ),
    );
  }
}
