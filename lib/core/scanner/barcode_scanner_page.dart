import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// What the camera read.
typedef ScanResult = ({String value, BarcodeFormat format});

/// Opens the camera and returns the first QR code (or barcode, when [qr] is
/// false) it reads, or `null` when the user cancels.
Future<ScanResult?> scanCode(BuildContext context, {required bool qr}) {
  return Navigator.of(
    context,
  ).push<ScanResult>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => BarcodeScannerPage(qr: qr)));
}

class BarcodeScannerPage extends StatefulWidget {
  final bool qr;

  const BarcodeScannerPage({super.key, required this.qr});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  static const _barcodeFormats = [
    BarcodeFormat.code128,
    BarcodeFormat.code39,
    BarcodeFormat.code93,
    BarcodeFormat.codabar,
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.itf14,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
    BarcodeFormat.qrCode,
  ];

  late final _controller = MobileScannerController(
    formats: widget.qr ? const [BarcodeFormat.qrCode] : _barcodeFormats,
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    final value = barcode?.rawValue;
    if (_done || barcode == null || value == null || value.isEmpty) return;
    _done = true;
    Navigator.of(context).pop((value: value, format: barcode.format));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: widget.qr ? 260 : 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: SafeArea(
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.commonCancel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
