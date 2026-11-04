import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/collection_page.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/categories/category_sheet.dart';
import 'package:shopping_list/features/categories/category_tile.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/sharing/import_sheet.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:shopping_list/features/sharing/share_sheet.dart';
import 'package:shopping_list/l10n/l10n.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  Future<void> _add(BuildContext context) async {
    final result = await showCategorySheet(context);
    if (result is! SaveCategory || !context.mounted) return;
    final input = result.input;
    final cubit = context.read<CategoriesCubit>();
    if (cubit.exists(input.label, input.color)) {
      showAppSnackBar(context, context.l10n.categoriesExists);
      return;
    }
    await cubit.add(input.label, input.color);
  }

  Future<void> _onAction(BuildContext context, CollectionAction action) async {
    final cubit = context.read<CategoriesCubit>();
    switch (action) {
      case CollectionAction.share:
        await showShareSheet(
          context,
          SharePayload(ShareKind.categories, cubit.state.map((c) => c.toMap()).toList()),
          what: context.l10n.shareWhatCategories(cubit.state.length),
        );
      case CollectionAction.import:
        await showImportSheet(context);
      case CollectionAction.delete:
        if (await confirmDelete(context, message: context.l10n.categoriesConfirmDeleteAll)) {
          await cubit.removeAll();
        }
      case CollectionAction.move:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoriesCubit>().state;
    final counts = <String, int>{};
    for (final article in context.watch<ListsCubit>().allArticles) {
      final id = article.category?.id;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }

    return CollectionPage<Category>(
      showBack: true,
      title: context.l10n.categoriesTitle,
      subtitle: categories.isEmpty ? null : context.l10n.settingsCategoriesCount(categories.length),
      items: categories,
      emptyIcon: Icons.category_outlined,
      emptyText: context.l10n.categoriesEmpty,
      addLabel: context.l10n.categoriesAdd,
      onAdd: () => _add(context),
      actions: const [CollectionAction.share, CollectionAction.import, CollectionAction.delete],
      reorderOnLongPress: true,
      onAction: (action) => _onAction(context, action),
      header: categories.isEmpty ? null : const _OrderHint(),
      keyOf: (category) => category.id,
      itemBuilder: (context, category, movable) =>
          CategoryTile(category: category, articleCount: counts[category.id] ?? 0),
      onReorder: context.read<CategoriesCubit>().reorder,
    );
  }
}

/// Why the order matters: it is the order of the aisles in every list.
class _OrderHint extends StatelessWidget {
  const _OrderHint();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Icon(Icons.route_rounded, color: colors.primary),
          Expanded(
            child: Text(
              context.l10n.categoriesOrderHint,
              style: TextTheme.of(context).bodyMedium!.copyWith(color: colors.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
