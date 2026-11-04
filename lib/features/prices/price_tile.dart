import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/features/categories/category_badge.dart';
import 'package:shopping_list/features/lists/article.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/prices/price.dart';
import 'package:shopping_list/features/prices/price_input_sheet.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// One amount: what it is for and how much. Tap it to change or delete it.
class PriceTile extends StatelessWidget {
  final Price price;

  /// The article the price is for, `null` for an amount added by hand.
  final Article? article;

  const PriceTile({super.key, required this.price, this.article});

  String _label(BuildContext context) => article?.label ?? context.l10n.calculatorWithoutArticle;

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<PricesCubit>();
    final label = _label(context);
    final result = await showPriceSheet(context, title: label, initialCents: price.cents);
    switch (result) {
      case SetPrice(:final cents):
        await cubit.update(price.copyWithCents(cents));
      case DeletePrice():
        final deleted = await cubit.remove(price.id);
        if (deleted == null || !context.mounted) return;
        showUndoSnackBar(
          context,
          message: context.l10n.commonDeleted('$label · ${formatAmount(context, price.amount)}'),
          onUndo: () => cubit.restore(deleted),
        );
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = TextTheme.of(context);
    final category = article?.category;

    return Card(
      child: InkWell(
        onTap: () => _edit(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
          child: Row(
            spacing: 12,
            children: [
              if (article != null)
                CategoryBadge(label: article!.label, color: category?.color ?? colors.primary)
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long_rounded, size: 20, color: colors.onSecondaryContainer),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_label(context), style: text.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
                    if (category != null)
                      Text(category.label, style: text.bodySmall!.copyWith(color: colors.outline)),
                  ],
                ),
              ),
              Text(
                formatAmount(context, price.amount),
                style: text.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
