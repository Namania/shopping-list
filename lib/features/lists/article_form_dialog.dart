import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/form_dialog.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/categories/uncategorized.dart';

typedef ArticleInput = ({String label, Category? category});

/// Asks for an article's name and category. Pass [initial] to edit an
/// article.
Future<ArticleInput?> showArticleFormDialog(BuildContext context, {ArticleInput? initial}) {
  final labelController = TextEditingController(text: initial?.label);
  final none = uncategorized(context);
  final categories = [none, ...context.read<CategoriesCubit>().state];
  // The category of the article may have been deleted since.
  var category = categories.contains(initial?.category) ? initial!.category! : none;

  return showFormDialog<ArticleInput>(
    context,
    title: initial == null ? context.l10n.listFormAddTitle : context.l10n.listFormEditTitle,
    submitLabel: initial == null ? context.l10n.commonAdd : context.l10n.commonSave,
    fields: [
      AppTextField(controller: labelController, hint: context.l10n.listFormLabelHint),
      AppDropdown<Category>(
        items: categories,
        initial: category,
        labelOf: (c) => c.label,
        onSelected: (value) => category = value,
      ),
    ],
    submit: () {
      final label = labelController.text.trim();
      if (label.isEmpty) return null;
      return (label: label, category: category == none ? null : category);
    },
  );
}
