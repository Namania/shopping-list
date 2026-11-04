import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

/// One article row inside its category group: a large checkbox, the label,
/// an edit pencil. Tap anywhere on the row to check it; long-press or the
/// pencil to edit; swipe to delete. With the calculator on, checking an
/// article asks for its price.
class ArticleTile extends StatelessWidget {
  final Article article;

  const ArticleTile({super.key, required this.article});

  Future<void> _toggle(BuildContext context) async {
    HapticFeedback.selectionClick();
    final lists = context.read<ListsCubit>();
    final prices = context.read<PricesCubit>();
    final calculator = context.read<SettingsCubit>().state.calculatorEnabled;
    await lists.toggleDone(article.id);
    if (!calculator || !context.mounted) return;

    if (article.done) {
      await prices.removeForArticle(article.id);
    } else {
      if (await showPriceSheet(context, title: article.label) case SetPrice(:final cents)) {
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
      message: context.l10n.commonDeleted(article.label),
      onUndo: () => cubit.restoreArticle(deleted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SwipeToDelete(
      id: article.id,
      card: false,
      confirm: () => confirmDelete(context, message: context.l10n.listConfirmDelete),
      onDeleted: () => _delete(context),
      child: InkWell(
        onTap: () => _toggle(context),
        onLongPress: () => _edit(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              Transform.scale(
                scale: 1.15,
                child: Checkbox(value: article.done, onChanged: (_) => _toggle(context)),
              ),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 160),
                  style: TextTheme.of(context).bodyLarge!.copyWith(
                    fontSize: 17,
                    color: article.done ? colors.outline : colors.onSurface,
                    decoration: article.done ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationColor: colors.outline,
                  ),
                  child: Text(article.label),
                ),
              ),
              EditButton(onPressed: () => _edit(context)),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
