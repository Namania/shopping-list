import 'package:shopping_list/core/utils/colors.dart';
import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';

/// The loyalty cards in a horizontal strip, so the barcode is one tap away
/// at the checkout. Hidden when there are no cards.
class CardStrip extends StatelessWidget {
  const CardStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<CardsCubit>().state;
    if (cards.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            context.l10n.cardsTitle,
            style: TextTheme.of(
              context,
            ).labelLarge!.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: MediaQuery.textScalerOf(context).scale(72),
            child: ListView.separated(
              // Bleeds to the screen edges while the first card lines up
              // with the page content.
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => CardChip(card: cards[index]),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small card in the card's own colour; tap to show its barcode.
class CardChip extends StatelessWidget {
  final LoyaltyCard card;

  const CardChip({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final onCard = ThemeData.estimateBrightnessForColor(card.color) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final edge = edgeFor(context, card.color);
    return Material(
      color: card.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: edge?.top ?? BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/cards/${card.id}'),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 128),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.label,
                  style: TextStyle(color: onCard, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  card.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onCard.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
