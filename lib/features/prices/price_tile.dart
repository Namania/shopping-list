import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/color_dot.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/edit_button.dart';
import 'package:shopping_list/core/ui/swipe_to_delete.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/features/lists/article.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/prices/price.dart';
import 'package:shopping_list/features/prices/price_input_sheet.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';

/// One amount of the calculator: tap or pencil to change it, swipe to delete.
class PriceTile extends StatelessWidget {
  final Price price;

  /// The article the price is for, `null` for an amount added by hand.
  final Article? article;

  const PriceTile({super.key, required this.price, this.article});

  Future<void> _edit(BuildContext context) async {
    final cents = await showPriceInputSheet(context, initialCents: price.cents);
    if (cents == null || !context.mounted) return;
    await context.read<PricesCubit>().update(price.copyWithCents(cents));
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = context.read<PricesCubit>();
    final deleted = await cubit.remove(price.id);
    if (deleted == null || !context.mounted) return;
    showUndoSnackBar(
      context,
      message: context.tr('common.deleted', args: [article?.label ?? formatAmount(context, price.amount)]),
      onUndo: () => cubit.restore(deleted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SwipeToDelete(
      id: price.id,
      confirm: () => confirmDelete(context, message: context.tr('calculator.confirm_delete')),
      onDeleted: () => _delete(context),
      child: ListTile(
        onTap: () => _edit(context),
        leading: ColorDot(article?.category?.color ?? colors.primary),
        title: Text(
          article?.label ?? context.tr('calculator.without_article'),
          style: TextTheme.of(context).bodyLarge!.apply(color: colors.primary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text(formatAmount(context, price.amount)), EditButton(onPressed: () => _edit(context))],
        ),
      ),
    );
  }
}
