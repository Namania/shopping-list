import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/ui/form_dialog.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';

/// Lets the user pick one of [cards] to link to a list.
Future<LoyaltyCard?> showLinkCardDialog(BuildContext context, {required List<LoyaltyCard> cards}) {
  var selected = cards.first;
  return showFormDialog<LoyaltyCard>(
    context,
    title: context.l10n.listLinkCardTitle,
    submitLabel: context.l10n.commonLink,
    fields: [
      AppDropdown<LoyaltyCard>(
        items: cards,
        initial: selected,
        labelOf: (card) => card.label,
        onSelected: (value) => selected = value,
      ),
    ],
    submit: () => selected,
  );
}
