import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/categories/category_badge.dart';
import 'package:shopping_list/features/categories/category_sheet.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// A category: its coloured badge, name and how many articles use it. Tap to
/// edit or delete it; long-press and drag to move it (the page handles that).
class CategoryTile extends StatelessWidget {
  final Category category;
  final int articleCount;

  const CategoryTile({super.key, required this.category, required this.articleCount});

  Future<void> _open(BuildContext context) async {
    final result = await showCategorySheet(context, initial: (label: category.label, color: category.color));
    if (!context.mounted) return;
    switch (result) {
      case SaveCategory(:final input):
        final cubit = context.read<CategoriesCubit>();
        if (cubit.exists(input.label, input.color, exceptId: category.id)) {
          showAppSnackBar(context, context.l10n.categoriesExists);
          return;
        }
        await cubit.update(category.copyWith(label: input.label, color: input.color));
      case DeleteCategory():
        await _delete(context);
      case null:
        break;
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await confirmDelete(
      context,
      message: articleCount == 0
          ? context.l10n.categoriesConfirmDelete
          : context.l10n.categoriesConfirmDeleteUsed(articleCount),
    );
    if (!confirmed || !context.mounted) return;
    final cubit = context.read<CategoriesCubit>();
    final deleted = await cubit.remove(category.id);
    if (deleted == null || !context.mounted) return;
    showUndoSnackBar(
      context,
      message: context.l10n.commonDeleted(category.label),
      onUndo: () => cubit.restore(deleted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = TextTheme.of(context);
    return Card(
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 14, 12),
          child: Row(
            spacing: 10,
            children: [
              // Shows the row can be moved: a long press anywhere lifts it.
              // (No tooltip: it would also open on a long press and steal the drag.)
              Semantics(
                label: context.l10n.categoriesReorderHint,
                child: Icon(Icons.drag_indicator_rounded, color: colors.outline),
              ),
              CategoryBadge(label: category.label, color: category.color),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(category.label, style: text.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      context.l10n.categoriesArticleCount(articleCount),
                      style: text.bodySmall!.copyWith(color: colors.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
