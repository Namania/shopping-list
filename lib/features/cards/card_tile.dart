import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/color_dot.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/edit_button.dart';
import 'package:shopping_list/core/ui/swipe_to_delete.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/features/cards/barcode_view.dart';
import 'package:shopping_list/features/cards/card_form_dialog.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';

/// A loyalty card: tap to unfold its barcode, pencil or long-press to edit,
/// swipe to delete.
class CardTile extends StatelessWidget {
  final LoyaltyCard card;
  final bool movable;

  const CardTile({super.key, required this.card, required this.movable});

  Future<void> _edit(BuildContext context) async {
    final input = await showCardFormDialog(
      context,
      initial: (label: card.label, code: card.code, color: card.color, format: card.format),
    );
    if (input == null || !context.mounted) return;
    await context.read<CardsCubit>().update(
      card.copyWith(label: input.label, code: input.code, color: input.color, format: input.format),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = context.read<CardsCubit>();
    final deleted = await cubit.remove(card.id);
    if (deleted == null || !context.mounted) return;
    showUndoSnackBar(
      context,
      message: context.tr('common.deleted', args: [card.label]),
      onUndo: () => cubit.restore(deleted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SwipeToDelete(
      id: card.id,
      confirm: () => confirmDelete(context, message: context.tr('cards.confirm_delete')),
      onDeleted: () => _delete(context),
      child: GestureDetector(
        onLongPress: () => _edit(context),
        child: ExpansionTile(
          leading: movable ? const Icon(Icons.drag_handle_rounded) : ColorDot(card.color),
          tilePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
          title: Text(card.label, style: TextTheme.of(context).bodyLarge!.apply(color: colors.onSurface)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(card.code, style: TextStyle(fontSize: 12, color: colors.primary)),
              EditButton(onPressed: () => _edit(context)),
            ],
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          children: [BarcodeView(card.code, format: card.format)],
        ),
      ),
    );
  }
}
