import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/ui/form_dialog.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';

/// Lets the user pick one of [cards] to link to a list.
Future<LoyaltyCard?> showLinkCardDialog(BuildContext context, {required List<LoyaltyCard> cards}) {
  var selected = cards.first;
  return showFormDialog<LoyaltyCard>(
    context,
    title: context.tr('list.link_card.title'),
    submitLabel: context.tr('common.link'),
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
