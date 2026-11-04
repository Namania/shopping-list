import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/features/cards/card_sheet.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// Opens the edit sheet of [card] and applies what the user chose. Returns
/// `true` when the card was deleted.
Future<bool> editCard(BuildContext context, LoyaltyCard card) async {
  final result = await showCardSheet(
    context,
    initial: (label: card.label, code: card.code, color: card.color, format: card.format),
  );
  if (!context.mounted) return false;
  switch (result) {
    case SaveCard(:final input):
      await context.read<CardsCubit>().update(
        card.copyWith(label: input.label, code: input.code, color: input.color, format: input.format),
      );
      return false;
    case DeleteCard():
      return deleteCard(context, card);
    case null:
      return false;
  }
}

/// Asks, deletes [card] and offers to undo. Returns `true` when deleted.
Future<bool> deleteCard(BuildContext context, LoyaltyCard card) async {
  if (!await confirmDelete(context, message: context.l10n.cardsConfirmDelete) || !context.mounted) {
    return false;
  }
  final cubit = context.read<CardsCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final message = context.l10n.commonDeleted(card.label);
  final deleted = await cubit.remove(card.id);
  if (deleted == null) return false;
  if (context.mounted) {
    showUndoSnackBar(context, message: message, onUndo: () => cubit.restore(deleted));
  } else {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
  return true;
}
