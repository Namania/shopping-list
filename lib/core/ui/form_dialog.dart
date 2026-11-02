import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// A dialog with form [fields] and cancel / submit buttons.
///
/// [submit] builds the result from the fields; it returns `null` when the
/// input is invalid, which keeps the dialog open.
Future<T?> showFormDialog<T>(
  BuildContext context, {
  required String title,
  required List<Widget> fields,
  required String submitLabel,
  required T? Function() submit,
}) {
  return showDialog<T>(
    context: context,
    builder:
        (context) => AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(title),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(mainAxisSize: MainAxisSize.min, spacing: 10, children: fields),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('common.cancel'))),
            TextButton(
              onPressed: () {
                final result = submit();
                if (result != null) Navigator.pop(context, result);
              },
              child: Text(submitLabel),
            ),
          ],
        ),
  );
}

/// A single-line text field as used in the app's forms.
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.name,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder(), suffixIcon: suffixIcon),
  );
}

/// A dropdown that selects one of [items], shown by [labelOf].
class AppDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T initial;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  const AppDropdown({
    super.key,
    required this.items,
    required this.initial,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => DropdownMenu<T>(
    // Fills the parent's width without a LayoutBuilder, which dialogs (they
    // measure their content's intrinsic size) cannot host.
    expandedInsets: EdgeInsets.zero,
    initialSelection: initial,
    onSelected: (value) {
      if (value != null) onSelected(value);
    },
    dropdownMenuEntries: [for (final item in items) DropdownMenuEntry(value: item, label: labelOf(item))],
    selectedTrailingIcon: const Icon(Icons.arrow_drop_up_rounded),
    trailingIcon: const Icon(Icons.arrow_drop_down_rounded),
  );
}

/// The HSL colour picker used for categories and cards.
class ColorPickerField extends StatelessWidget {
  final Color initial;
  final ValueChanged<Color> onChanged;

  const ColorPickerField({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: ColorPicker(
      pickerColor: initial,
      onColorChanged: onChanged,
      hexInputBar: false,
      displayThumbColor: false,
      labelTypes: const [],
      enableAlpha: false,
      pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(5)),
      pickerAreaHeightPercent: .5,
      paletteType: PaletteType.hsl,
    ),
  );
}
