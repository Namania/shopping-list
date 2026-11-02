import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/color_dot.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/edit_button.dart';
import 'package:shopping_list/core/ui/swipe_to_delete.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/features/lists/article.dart';
import 'package:shopping_list/features/lists/article_form_dialog.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/prices/price_input_sheet.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';

/// An article: check it off, pencil or long-press to edit, swipe to delete.
/// With the calculator on, checking an article asks for its price.
class ArticleTile extends StatelessWidget {
  final Article article;

  const ArticleTile({super.key, required this.article});

  Future<void> _toggle(BuildContext context) async {
    final lists = context.read<ListsCubit>();
    final prices = context.read<PricesCubit>();
    final calculator = context.read<SettingsCubit>().state.calculatorEnabled;
    await lists.toggleDone(article.id);
    if (!calculator || !context.mounted) return;

    if (article.done) {
      await prices.removeForArticle(article.id);
    } else {
      final cents = await showPriceInputSheet(context);
      if (cents != null) {
        await prices.setForArticle(listId: article.listId, articleId: article.id, cents: cents);
      }
    }
  }

  Future<void> _edit(BuildContext context) async {
    final input = await showArticleFormDialog(
      context,
      initial: (label: article.label, category: article.category),
    );
    if (input == null || !context.mounted) return;
    await context.read<ListsCubit>().updateArticle(
      article.copyWith(label: input.label, category: input.category, clearCategory: input.category == null),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = context.read<ListsCubit>();
    final deleted = await cubit.removeArticle(article.id);
    if (deleted == null || !context.mounted) return;
    showUndoSnackBar(
      context,
      message: context.tr('common.deleted', args: [article.label]),
      onUndo: () => cubit.restoreArticle(deleted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SwipeToDelete(
      id: article.id,
      confirm: () => confirmDelete(context, message: context.tr('list.confirm_delete')),
      onDeleted: () => _delete(context),
      child: GestureDetector(
        onLongPress: () => _edit(context),
        child: CheckboxListTile(
          activeColor: colors.tertiary,
          controlAffinity: ListTileControlAffinity.leading,
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorDot(article.done ? colors.outline : (article.category?.color ?? colors.primary)),
              EditButton(onPressed: () => _edit(context)),
            ],
          ),
          title: Text(
            article.label,
            style: TextTheme.of(context).bodyLarge!.apply(
              color: article.done ? colors.outline : colors.primary,
              decoration: article.done ? TextDecoration.lineThrough : TextDecoration.none,
              decorationColor: colors.outline,
            ),
          ),
          value: article.done,
          onChanged: (_) => _toggle(context),
        ),
      ),
    );
  }
}
