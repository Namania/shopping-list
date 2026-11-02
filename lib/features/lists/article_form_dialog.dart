import 'package:easy_localization/easy_localization.dart';
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
    title: context.tr(initial == null ? 'list.form.add_title' : 'list.form.edit_title'),
    submitLabel: context.tr(initial == null ? 'common.add' : 'common.save'),
    fields: [
      AppTextField(controller: labelController, hint: context.tr('list.form.label_hint')),
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
