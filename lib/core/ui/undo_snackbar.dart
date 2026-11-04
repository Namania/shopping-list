import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Tells the user something was deleted and lets them take it back.
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required Future<void> Function() onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message, style: TextTheme.of(context).labelLarge),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(label: context.l10n.commonUndo, onPressed: onUndo),
    ),
  );
}
