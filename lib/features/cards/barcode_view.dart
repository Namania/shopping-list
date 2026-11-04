import 'package:barcode_widget/barcode_widget.dart';
import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/features/cards/card_format.dart';

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
          context.l10n.cardsInvalidCode(format.label),
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
