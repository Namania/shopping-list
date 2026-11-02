import 'package:barcode_widget/barcode_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as scanner;

/// The symbology a loyalty card is printed with. Stored with the card so it
/// is rendered the way the store's scanners expect it.
enum CardFormat {
  code128('Code 128'),
  ean13('EAN-13'),
  ean8('EAN-8'),
  upcA('UPC-A'),
  upcE('UPC-E'),
  code39('Code 39'),
  code93('Code 93'),
  codabar('Codabar'),
  itf14('ITF-14'),
  qrCode('QR code');

  final String label;
  const CardFormat(this.label);

  Barcode get barcode => switch (this) {
    code128 => Barcode.code128(),
    ean13 => Barcode.ean13(),
    ean8 => Barcode.ean8(),
    upcA => Barcode.upcA(),
    upcE => Barcode.upcE(),
    code39 => Barcode.code39(),
    code93 => Barcode.code93(),
    codabar => Barcode.codabar(),
    itf14 => Barcode.itf14(),
    qrCode => Barcode.qrCode(),
  };

  /// Whether [code] can be drawn with this symbology.
  bool accepts(String code) => barcode.isValid(code);

  static CardFormat fromName(String? name) =>
      values.where((f) => f.name == name).firstOrNull ?? CardFormat.code128;

  /// The format the camera recognized, `null` for symbologies the app does
  /// not print.
  static CardFormat? fromScanner(scanner.BarcodeFormat format) => switch (format) {
    scanner.BarcodeFormat.code128 => code128,
    scanner.BarcodeFormat.ean13 => ean13,
    scanner.BarcodeFormat.ean8 => ean8,
    scanner.BarcodeFormat.upcA => upcA,
    scanner.BarcodeFormat.upcE => upcE,
    scanner.BarcodeFormat.code39 => code39,
    scanner.BarcodeFormat.code93 => code93,
    scanner.BarcodeFormat.codabar => codabar,
    scanner.BarcodeFormat.itf14 => itf14,
    scanner.BarcodeFormat.qrCode => qrCode,
    _ => null,
  };
}
