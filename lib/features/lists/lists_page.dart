import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/collection_page.dart';
import 'package:shopping_list/features/categories/uncategorized.dart';
import 'package:shopping_list/features/lists/list_form_dialog.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';
import 'package:shopping_list/features/lists/shopping_list_tile.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/sharing/import_sheet.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:shopping_list/features/sharing/share_sheet.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  Future<void> _add(BuildContext context) async {
    final label = await showListFormDialog(context);
    if (label == null || !context.mounted) return;
    final added = await context.read<ListsCubit>().add(label);
    if (!added && context.mounted) showAppSnackBar(context, context.tr('lists.exists', args: [label]));
  }

  void _onAction(BuildContext context, CollectionAction action) {
    switch (action) {
      case CollectionAction.share:
        final none = uncategorized(context);
        final lists = context.read<ListsCubit>().state.map((l) => l.toMap(uncategorized: none)).toList();
        showShareSheet(context, SharePayload(ShareKind.lists, lists));
      case CollectionAction.import:
        showImportSheet(context, kind: ShareKind.lists);
      case CollectionAction.move:
      case CollectionAction.delete:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lists = context.watch<ListsCubit>().state;
    final calculator = context.watch<SettingsCubit>().state.calculatorEnabled;
    return CollectionPage<ShoppingList>(
      title: context.tr('lists.title'),
      items: lists,
      emptyText: context.tr('lists.empty'),
      addLabel: context.tr('lists.add'),
      onAdd: () => _add(context),
      actions: const [CollectionAction.share, CollectionAction.import, CollectionAction.move],
      onAction: (action) => _onAction(context, action),
      extraActions: [if (calculator) const AmountButton()],
      keyOf: (list) => list.id,
      itemBuilder: (context, list, movable) => ShoppingListTile(list: list, movable: movable),
      onReorder: context.read<ListsCubit>().reorder,
    );
  }
}
