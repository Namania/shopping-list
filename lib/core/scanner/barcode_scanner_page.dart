import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';

class HandleScaning {
  static Future<String> scan(BuildContext context, ScanMode mode) async {
    String barcodeScanRes = '';
    try {
      String res = await FlutterBarcodeScanner.scanBarcode(
        "#ffffff",
        context.tr('core.cancel_scan'),
        false,
        mode,
      );
      if (res != "-1") {
        barcodeScanRes = res;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du scan");
      }
    }
    return barcodeScanRes;
  }
}
