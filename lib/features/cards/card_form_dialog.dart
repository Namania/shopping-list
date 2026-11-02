import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/scanner/barcode_scanner_page.dart';
import 'package:shopping_list/core/ui/form_dialog.dart';
import 'package:shopping_list/core/utils/strings.dart';
import 'package:shopping_list/features/cards/card_format.dart';

/// Values entered in the card form.
typedef CardInput = ({String label, String code, Color color, CardFormat format});

/// Asks for a card's store, code, barcode format and colour. Pass [initial]
/// to edit a card. Scanning a card fills the code and its format.
Future<CardInput?> showCardFormDialog(BuildContext context, {CardInput? initial}) {
  final labelController = TextEditingController(text: initial?.label);
  final codeController = TextEditingController(text: initial?.code);
  final format = ValueNotifier(initial?.format ?? CardFormat.code128);
  var color = initial?.color ?? Theme.of(context).colorScheme.primary;

  return showFormDialog<CardInput>(
    context,
    title: context.tr(initial == null ? 'cards.form.add_title' : 'cards.form.edit_title'),
    submitLabel: context.tr(initial == null ? 'common.add' : 'common.save'),
    fields: [
      AppTextField(controller: labelController, hint: context.tr('cards.form.name_hint')),
      AppTextField(
        controller: codeController,
        hint: context.tr('cards.form.code_hint'),
        keyboardType: TextInputType.streetAddress,
        suffixIcon: IconButton(
          icon: const Icon(Icons.camera_alt_rounded),
          onPressed: () async {
            final scanned = await scanCode(context, qr: false);
            if (scanned == null) return;
            codeController.text = scanned.value;
            format.value = CardFormat.fromScanner(scanned.format) ?? CardFormat.code128;
          },
        ),
      ),
      ValueListenableBuilder(
        valueListenable: format,
        builder:
            (context, value, _) => AppDropdown<CardFormat>(
              key: ValueKey(value),
              items: CardFormat.values,
              initial: value,
              labelOf: (f) => f.label,
              onSelected: (f) => format.value = f,
            ),
      ),
      ColorPickerField(initial: color, onChanged: (value) => color = value),
    ],
    submit: () {
      final label = labelController.text.trim();
      final code = codeController.text.trim();
      if (label.isEmpty || code.isEmpty) return null;
      return (label: capitalize(label), code: code, color: color, format: format.value);
    },
  );
}
