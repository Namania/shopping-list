import 'package:barcode_widget/barcode_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/ui/app_bottom_sheet.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/features/cards/loyalty_card.dart';

/// The barcode of a loyalty card in its own symbology, on white so scanners
/// can read it. A code the symbology cannot encode shows a message instead.
class BarcodeView extends StatelessWidget {
  final String code;
  final CardFormat format;

  const BarcodeView(this.code, {super.key, required this.format});

  @override
  Widget build(BuildContext context) {
    if (!format.accepts(code)) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          context.tr('cards.invalid_code', args: [format.label]),
          textAlign: TextAlign.center,
          style: TextTheme.of(context).bodyMedium!.apply(color: Theme.of(context).colorScheme.error),
        ),
      );
    }
    final square = format == CardFormat.qrCode;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(30),
      child: BarcodeWidget(
        barcode: format.barcode,
        data: code,
        drawText: false,
        height: square ? 200 : null,
        width: square ? 200 : null,
      ),
    );
  }
}

Future<void> showBarcodeSheet(BuildContext context, LoyaltyCard card) {
  return showAppBottomSheet<void>(
    context,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(card.label, style: TextTheme.of(context).titleLarge),
      ),
      BarcodeView(card.code, format: card.format),
    ],
  );
}
