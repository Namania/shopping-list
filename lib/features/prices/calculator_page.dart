import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/app_bottom_sheet.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/prices/price_input_sheet.dart';
import 'package:shopping_list/features/prices/price_tile.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';

/// The amounts of one list, or of every list when [listId] is `null`.
class CalculatorPage extends StatelessWidget {
  final String? listId;

  const CalculatorPage({super.key, this.listId});

  Future<void> _addAmount(BuildContext context) async {
    final cents = await showPriceInputSheet(context);
    if (cents == null || !context.mounted) return;
    await context.read<PricesCubit>().addManual(cents: cents, listId: listId);
  }

  /// Offers to clear the amounts tied to an article, the ones added by hand,
  /// or everything.
  void _askClear(BuildContext context) {
    final prices = context.read<PricesCubit>();
    void clear(bool? linked) {
      prices.clear(linked: linked);
      Navigator.of(context).pop();
    }

    showAppBottomSheet<void>(
      context,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: Text(context.tr('calculator.clear.title'), textAlign: TextAlign.center),
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.article_rounded),
                onPressed: () => clear(true),
                label: Text(context.tr('calculator.clear.with_article'), textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.close),
                onPressed: () => clear(false),
                label: Text(context.tr('calculator.clear.without_article'), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.delete),
              onPressed: () => clear(null),
              label: Text(context.tr('calculator.clear.all')),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricesCubit = context.watch<PricesCubit>();
    final prices = pricesCubit.forList(listId);
    final articles = context.watch<ListsCubit>().allArticles;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(context.tr('calculator.title')),
        actions: [
          if (listId == null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(onPressed: () => _askClear(context), icon: const Icon(Icons.delete)),
            ),
        ],
      ),
      body:
          prices.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(context.tr('calculator.empty'), textAlign: TextAlign.center),
                ),
              )
              : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 60),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                    child: Text(
                      '${context.tr('calculator.total')}\n${formatAmount(context, pricesCubit.total(listId))}',
                      textAlign: TextAlign.center,
                      style: TextTheme.of(
                        context,
                      ).displaySmall!.apply(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  const Divider(indent: 10, endIndent: 10),
                  const SizedBox(height: 20),
                  for (final price in prices)
                    PriceTile(
                      key: ValueKey(price.id),
                      price: price,
                      article: articles.where((a) => a.id == price.articleId).firstOrNull,
                    ),
                ],
              ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          icon: const Icon(Icons.add),
          onPressed: () => _addAmount(context),
          label: Text(context.tr('calculator.add_button')),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
