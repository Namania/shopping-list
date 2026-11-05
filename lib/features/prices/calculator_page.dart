import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/page_body.dart';
import 'package:shopping_list/core/ui/collection_page.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/empty_state.dart';
import 'package:shopping_list/core/ui/movable_list.dart';
import 'package:shopping_list/core/ui/page_header.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/prices/price.dart';
import 'package:shopping_list/features/prices/price_input_sheet.dart';
import 'package:shopping_list/features/prices/price_tile.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// The amounts of one list, or of every list when [listId] is `null`: the
/// total up top, then each amount; across all lists they are grouped by list.
class CalculatorPage extends StatelessWidget {
  final String? listId;

  const CalculatorPage({super.key, this.listId});

  Future<void> _addAmount(BuildContext context) async {
    final prices = context.read<PricesCubit>();
    if (await showPriceSheet(context) case SetPrice(:final cents)) {
      await prices.addManual(cents: cents, listId: listId);
    }
  }

  /// Offers to clear the amounts tied to an article, the ones added by hand,
  /// or everything.
  Future<void> _askClear(BuildContext context) async {
    final prices = context.read<PricesCubit>();
    final l10n = context.l10n;
    final linked = await showChoiceDialog<(bool?,)?>(
      context,
      message: l10n.calculatorClearTitle,
      icon: Icons.delete_sweep_outlined,
      choices: [
        Choice(l10n.calculatorClearWithArticle, (true,)),
        Choice(l10n.calculatorClearWithoutArticle, (false,)),
        Choice(l10n.calculatorClearAll, (null,), destructive: true),
        Choice(l10n.commonCancel, null, primary: false),
      ],
    );
    if (linked != null) await prices.clear(listId: listId, linked: linked.$1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pricesCubit = context.watch<PricesCubit>();
    final listsCubit = context.watch<ListsCubit>();
    final prices = pricesCubit.forList(listId);
    final articles = {for (final a in listsCubit.allArticles) a.id: a};
    final list = listId == null ? null : listsCubit.byId(listId!);

    Widget tile(Price price) =>
        PriceTile(key: ValueKey(price.id), price: price, article: articles[price.articleId]);

    // Across all lists: one group per list, in the lists' order, then the
    // amounts that belong to none.
    final groups = <(String?, List<Price>)>[
      if (listId == null) ...[
        for (final l in listsCubit.state)
          if (prices.where((p) => p.listId == l.id).toList() case final group when group.isNotEmpty)
            (l.label, group),
        if (prices.where((p) => listsCubit.byId(p.listId ?? '') == null).toList() case final group
            when group.isNotEmpty)
          (l10n.calculatorNoList, group),
      ] else
        (null, prices),
    ];

    return Scaffold(
      body: PageBody(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: l10n.calculatorTitle,
              subtitle: list?.label ?? l10n.calculatorAllLists,
              showBack: true,
              actions: [
                if (prices.isNotEmpty)
                  IconButton(
                    tooltip: l10n.calculatorClearAll,
                    onPressed: () => _askClear(context),
                    icon: const Icon(Icons.delete_sweep_outlined),
                  ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: MovableList.padding,
                children: [
                  _TotalCard(total: pricesCubit.total(listId), count: prices.length),
                  if (prices.isEmpty)
                    EmptyState(icon: Icons.calculate_rounded, text: l10n.calculatorEmpty)
                  else
                    for (final (title, group) in groups) ...[
                      if (title != null) _GroupHeader(title: title, prices: group),
                      for (final price in group) tile(price),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AddButton(label: l10n.calculatorAddButton, onPressed: () => _addAmount(context)),
    );
  }
}

/// The total, large, with how many amounts make it.
class _TotalCard extends StatelessWidget {
  final double total;
  final int count;

  const _TotalCard({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = TextTheme.of(context);
    return Card(
      color: colors.primaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          spacing: 4,
          children: [
            Text(
              context.l10n.calculatorTotal.toUpperCase(),
              style: text.labelMedium!.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(end: total),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FittedBox(
                child: Text(
                  formatAmount(context, value),
                  style: text.displayMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimaryContainer,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            Text(
              context.l10n.calculatorCount(count),
              style: text.bodyMedium!.copyWith(color: colors.onPrimaryContainer.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list's name and its subtotal, above its amounts.
class _GroupHeader extends StatelessWidget {
  final String title;
  final List<Price> prices;

  const _GroupHeader({required this.title, required this.prices});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = TextTheme.of(
      context,
    ).labelMedium!.copyWith(color: colors.outline, fontWeight: FontWeight.w700, letterSpacing: 0.8);
    final subtotal = prices.fold(0, (sum, p) => sum + p.cents) / 100;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 6),
      child: Row(
        spacing: 12,
        children: [
          Expanded(child: Text(title.toUpperCase(), style: style)),
          Text(formatAmount(context, subtotal), style: style),
        ],
      ),
    );
  }
}
