import 'package:flutter/material.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// One button of a [showChoiceDialog]. [primary] buttons are filled;
/// [destructive] ones are filled in the error colour.
class Choice<T> {
  final String label;
  final T value;
  final bool primary;
  final bool destructive;

  const Choice(this.label, this.value, {this.primary = true, this.destructive = false});
}

/// A question in a bottom sheet, answered by one of the stacked full-width
/// [choices]. `null` when the sheet is dismissed.
Future<T?> showChoiceDialog<T>(
  BuildContext context, {
  required String message,
  required List<Choice<T>> choices,
  IconData? icon,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      final destructive = choices.any((c) => c.destructive);
      return SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              if (icon != null || destructive)
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: destructive ? colors.errorContainer : colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ?? Icons.delete_outline_rounded,
                      color: destructive ? colors.onErrorContainer : colors.primary,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextTheme.of(context).titleMedium!.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              for (final choice in choices)
                choice.destructive
                    ? FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.error,
                          foregroundColor: colors.onError,
                        ),
                        onPressed: () => Navigator.of(context).pop(choice.value),
                        child: Text(choice.label),
                      )
                    : choice.primary
                    ? FilledButton(
                        onPressed: () => Navigator.of(context).pop(choice.value),
                        child: Text(choice.label),
                      )
                    : OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(choice.value),
                        child: Text(choice.label),
                      ),
            ],
          ),
        ),
      );
    },
  );
}

/// Asks before a deletion, in a bottom sheet. [confirmLabel] names the
/// action ("Delete" by default).
Future<bool> confirmDelete(BuildContext context, {required String message, String? confirmLabel}) async {
  final confirmed = await showChoiceDialog<bool>(
    context,
    message: message,
    choices: [
      Choice(confirmLabel ?? context.l10n.commonDelete, true, destructive: true),
      Choice(context.l10n.commonCancel, false, primary: false),
    ],
  );
  return confirmed ?? false;
}
