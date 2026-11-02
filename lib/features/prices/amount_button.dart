import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';

/// Formats an amount with the currency of the current locale.
String formatAmount(BuildContext context, double amount) =>
    context.tr('calculator.amount', args: [amount.toStringAsFixed(2)]);

/// The running total of one list (or of every list), opening the calculator.
class AmountButton extends StatelessWidget {
  final String? listId;

  const AmountButton({super.key, this.listId});

  @override
  Widget build(BuildContext context) {
    final total = context.watch<PricesCubit>().total(listId);
    return TextButton(
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStatePropertyAll(Size.fromRadius(20)),
      ),
      onPressed:
          () => context.push(
            Uri(path: '/calculator', queryParameters: {if (listId != null) 'list': listId}).toString(),
          ),
      child: Text(
        formatAmount(context, total),
        style: TextTheme.of(context).bodyMedium!.apply(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
