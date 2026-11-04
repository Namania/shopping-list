import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/collection_page.dart';
import 'package:shopping_list/features/cards/card_sheet.dart';
import 'package:shopping_list/features/cards/card_tile.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';
import 'package:shopping_list/features/sharing/import_sheet.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:shopping_list/features/sharing/share_sheet.dart';
import 'package:shopping_list/l10n/l10n.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  Future<void> _add(BuildContext context) async {
    final result = await showCardSheet(context);
    if (result is! SaveCard || !context.mounted) return;
    final input = result.input;
    await context.read<CardsCubit>().add(
      label: input.label,
      code: input.code,
      color: input.color,
      format: input.format,
    );
  }

  void _onAction(BuildContext context, CollectionAction action) {
    final cubit = context.read<CardsCubit>();
    switch (action) {
      case CollectionAction.share:
        showShareSheet(
          context,
          SharePayload(ShareKind.cards, cubit.state.map((c) => c.toMap()).toList()),
          what: context.l10n.shareWhatCards(cubit.state.length),
        );
      case CollectionAction.import:
        showImportSheet(context);
      case CollectionAction.move:
      case CollectionAction.delete:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<CardsCubit>().state;
    return CollectionPage<LoyaltyCard>(
      title: context.l10n.cardsTitle,
      subtitle: cards.isEmpty ? null : context.l10n.cardsCount(cards.length),
      items: cards,
      emptyIcon: Icons.credit_card_rounded,
      emptyText: context.l10n.cardsEmpty,
      addLabel: context.l10n.cardsAdd,
      onAdd: () => _add(context),
      actions: const [CollectionAction.share, CollectionAction.import],
      reorderOnLongPress: true,
      onAction: (action) => _onAction(context, action),
      keyOf: (card) => card.id,
      itemBuilder: (context, card, movable) => CardTile(card: card),
      onReorder: context.read<CardsCubit>().reorder,
    );
  }
}
