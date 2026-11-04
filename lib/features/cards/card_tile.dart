import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/features/cards/card_face.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// A loyalty card in the list: tap to show it full screen; long-press and
/// drag to move it (the page handles that).
class CardTile extends StatelessWidget {
  final LoyaltyCard card;

  const CardTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final linked = context.watch<ListsCubit>().state.where((l) => l.cardId == card.id).map((l) => l.label);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/cards/${card.id}'),
          child: CardFace(
            label: card.label,
            code: card.code,
            color: card.color,
            format: card.format,
            footer: linked.isEmpty ? null : context.l10n.cardsUsedFor(linked.join(', ')),
            leading: Semantics(
              label: context.l10n.categoriesReorderHint,
              child: Icon(
                Icons.drag_indicator_rounded,
                color: CardFace.onColor(card.color).withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
