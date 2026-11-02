import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/collection_page.dart';
import 'package:shopping_list/features/cards/card_form_dialog.dart';
import 'package:shopping_list/features/cards/card_tile.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';
import 'package:shopping_list/features/sharing/import_sheet.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:shopping_list/features/sharing/share_sheet.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  Future<void> _add(BuildContext context) async {
    final input = await showCardFormDialog(context);
    if (input == null || !context.mounted) return;
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
        showShareSheet(context, SharePayload(ShareKind.cards, cubit.state.map((c) => c.toMap()).toList()));
      case CollectionAction.import:
        showImportSheet(context, kind: ShareKind.cards);
      case CollectionAction.move:
      case CollectionAction.delete:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<CardsCubit>().state;
    return CollectionPage<LoyaltyCard>(
      title: context.tr('cards.title'),
      items: cards,
      emptyText: context.tr('cards.empty'),
      addLabel: context.tr('cards.add'),
      onAdd: () => _add(context),
      actions: const [CollectionAction.share, CollectionAction.import, CollectionAction.move],
      onAction: (action) => _onAction(context, action),
      keyOf: (card) => card.id,
      itemBuilder: (context, card, movable) => CardTile(card: card, movable: movable),
      onReorder: context.read<CardsCubit>().reorder,
    );
  }
}
