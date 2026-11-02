import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// One button of a [showChoiceDialog]. [primary] buttons are filled.
class Choice<T> {
  final String label;
  final T value;
  final bool primary;

  const Choice(this.label, this.value, {this.primary = true});
}

/// A confirmation dialog with stacked full-width buttons.
Future<T?> showChoiceDialog<T>(
  BuildContext context, {
  required String message,
  required List<Choice<T>> choices,
}) {
  return showDialog<T>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(context.tr('common.confirm')),
          content: Text(message),
          actions: [
            for (final choice in choices)
              SizedBox(
                width: double.infinity,
                child:
                    choice.primary
                        ? FilledButton(
                          onPressed: () => Navigator.of(context).pop(choice.value),
                          child: Text(choice.label),
                        )
                        : OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(choice.value),
                          child: Text(choice.label),
                        ),
              ),
          ],
        ),
  );
}

/// Asks "yes / no" before a deletion.
Future<bool> confirmDelete(BuildContext context, {required String message}) async {
  final confirmed = await showChoiceDialog<bool>(
    context,
    message: message,
    choices: [Choice(context.tr('common.no'), false, primary: false), Choice(context.tr('common.yes'), true)],
  );
  return confirmed ?? false;
}
