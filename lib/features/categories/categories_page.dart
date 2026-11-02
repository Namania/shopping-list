import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/collection_page.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/categories/category_form_dialog.dart';
import 'package:shopping_list/features/categories/category_tile.dart';
import 'package:shopping_list/features/sharing/import_sheet.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:shopping_list/features/sharing/share_sheet.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  Future<void> _add(BuildContext context) async {
    final input = await showCategoryFormDialog(context);
    if (input == null || !context.mounted) return;
    await context.read<CategoriesCubit>().add(input.label, input.color);
  }

  Future<void> _onAction(BuildContext context, CollectionAction action) async {
    final cubit = context.read<CategoriesCubit>();
    switch (action) {
      case CollectionAction.share:
        await showShareSheet(
          context,
          SharePayload(ShareKind.categories, cubit.state.map((c) => c.toMap()).toList()),
        );
      case CollectionAction.import:
        await showImportSheet(context, kind: ShareKind.categories);
      case CollectionAction.delete:
        if (await confirmDelete(context, message: context.tr('categories.confirm_delete_all'))) {
          await cubit.removeAll();
        }
      case CollectionAction.move:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoriesCubit>().state;
    return CollectionPage<Category>(
      title: context.tr('categories.title'),
      items: categories,
      emptyText: context.tr('categories.empty'),
      addLabel: context.tr('categories.add'),
      onAdd: () => _add(context),
      actions: CollectionAction.values,
      onAction: (action) => _onAction(context, action),
      keyOf: (category) => category.id,
      itemBuilder: (context, category, movable) => CategoryTile(category: category, movable: movable),
      onReorder: context.read<CategoriesCubit>().reorder,
    );
  }
}
