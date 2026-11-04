import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';

/// Formats an amount the way the app's language writes it: "10,08 €" in
/// French, "$10.08" in English.
String formatAmount(BuildContext context, double amount) => context.l10n.calculatorAmount(
  NumberFormat.decimalPatternDigits(
    locale: Localizations.localeOf(context).toString(),
    decimalDigits: 2,
  ).format(amount),
);

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
      onPressed: () => context.push(
        Uri(path: '/calculator', queryParameters: {if (listId != null) 'list': listId}).toString(),
      ),
      child: Text(
        formatAmount(context, total),
        style: TextTheme.of(context).bodyMedium!.apply(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
