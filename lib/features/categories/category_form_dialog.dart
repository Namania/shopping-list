import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/ui/form_dialog.dart';
import 'package:shopping_list/core/utils/strings.dart';

typedef CategoryInput = ({String label, Color color});

/// Asks for a category's name and colour. Pass [initial] to edit a category.
Future<CategoryInput?> showCategoryFormDialog(BuildContext context, {CategoryInput? initial}) {
  final labelController = TextEditingController(text: initial?.label);
  var color = initial?.color ?? Theme.of(context).colorScheme.primary;

  return showFormDialog<CategoryInput>(
    context,
    title: context.tr(initial == null ? 'categories.form.add_title' : 'categories.form.edit_title'),
    submitLabel: context.tr(initial == null ? 'common.add' : 'common.save'),
    fields: [
      AppTextField(controller: labelController, hint: context.tr('categories.form.name_hint')),
      ColorPickerField(initial: color, onChanged: (value) => color = value),
    ],
    submit: () {
      final label = labelController.text.trim();
      if (label.isEmpty) return null;
      return (label: capitalize(label), color: color);
    },
  );
}
