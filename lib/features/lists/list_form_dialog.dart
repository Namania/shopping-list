import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/ui/form_dialog.dart';

/// Asks for a list's name. Pass [initial] to rename a list.
Future<String?> showListFormDialog(BuildContext context, {String? initial}) {
  final labelController = TextEditingController(text: initial);
  return showFormDialog<String>(
    context,
    title: context.tr(initial == null ? 'lists.form.add_title' : 'lists.form.edit_title'),
    submitLabel: context.tr(initial == null ? 'common.add' : 'common.save'),
    fields: [AppTextField(controller: labelController, hint: context.tr('lists.form.label_hint'))],
    submit: () {
      final label = labelController.text.trim();
      return label.isEmpty ? null : label;
    },
  );
}
