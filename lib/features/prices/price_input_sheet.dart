import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_list/core/ui/app_bottom_sheet.dart';

/// Asks for an amount and returns it in cents. The amount is taken both when
/// the keyboard's "done" is pressed and when the sheet is dismissed, so a
/// tap outside also validates. Returns `null` when nothing was typed.
/// [initialCents] pre-fills the field to edit an existing amount.
Future<int?> showPriceInputSheet(BuildContext context, {int? initialCents}) async {
  final controller = TextEditingController(
    text: initialCents == null ? '' : (initialCents / 100).toStringAsFixed(2),
  );
  await showAppBottomSheet<void>(
    context,
    children: [
      TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_AmountFormatter()],
        decoration: InputDecoration(
          hintText: context.tr('calculator.add_hint'),
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => Navigator.pop(context),
      ),
      SheetHint(context.tr('calculator.tap_outside')),
    ],
  );
  final amount = double.tryParse(controller.text.replaceAll(',', '.'));
  return amount == null ? null : (amount * 100).round();
}

/// Accepts digits with at most two decimals; an edit that would break that
/// is refused rather than clearing the field.
class _AmountFormatter extends TextInputFormatter {
  static final _valid = RegExp(r'^\d*([.,]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      _valid.hasMatch(newValue.text) ? newValue : oldValue;
}
