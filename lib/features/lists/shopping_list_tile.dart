import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/edit_button.dart';
import 'package:shopping_list/core/ui/swipe_to_delete.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/features/cards/barcode_view.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/lists/list_form_dialog.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';

/// A shopping list: tap to open, pencil or long-press to rename, swipe to
/// delete.
class ShoppingListTile extends StatelessWidget {
  final ShoppingList list;
  final bool movable;

  const ShoppingListTile({super.key, required this.list, required this.movable});

  Future<void> _rename(BuildContext context) async {
    final label = await showListFormDialog(context, initial: list.label);
    if (label == null || !context.mounted) return;
    await context.read<ListsCubit>().update(list.copyWith(label: label));
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = context.read<ListsCubit>();
    final deleted = await cubit.remove(list.id);
    if (deleted == null || !context.mounted) return;
    showUndoSnackBar(
      context,
      message: context.tr('common.deleted', args: [list.label]),
      onUndo: () => cubit.restore(deleted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final card = context.watch<CardsCubit>().byId(list.cardId);
    final calculator = context.watch<SettingsCubit>().state.calculatorEnabled;

    return SwipeToDelete(
      id: list.id,
      confirm: () => confirmDelete(context, message: context.tr('lists.confirm_delete')),
      onDeleted: () => _delete(context),
      child: GestureDetector(
        onLongPress: () => _rename(context),
        onTap: () => context.push('/lists/${list.id}'),
        child: ListTile(
          leading: movable ? const Icon(Icons.drag_handle_rounded) : null,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Row(
                      children: [
                        Text(list.label, style: TextTheme.of(context).titleLarge),
                        if (!movable) EditButton(onPressed: () => _rename(context)),
                      ],
                    ),
                    if (card != null)
                      IconButton.outlined(
                        color: colors.tertiary,
                        iconSize: 20,
                        style: ButtonStyle(side: WidgetStatePropertyAll(BorderSide(color: colors.tertiary))),
                        onPressed: () => showBarcodeSheet(context, card),
                        icon: const Icon(Icons.credit_card_rounded),
                      ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(context.plural('lists.count', list.articles.length)),
                    if (calculator) AmountButton(listId: list.id),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
