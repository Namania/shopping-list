import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopping_list/core/ui/app_bottom_sheet.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';

/// Largest deep link a QR code can hold (version 40, low error correction,
/// byte mode), with some margin.
const _maxQrBytes = 2900;

/// Shows a QR code another phone can scan, with a button to send the same
/// data as a JSON file instead. Too much data for a QR code leaves only the
/// file option.
Future<void> showShareSheet(BuildContext context, SharePayload payload) {
  final deepLink = payload.toDeepLink();
  final fits = utf8.encode(deepLink).length <= _maxQrBytes;
  return showAppBottomSheet<void>(
    context,
    children: [
      if (fits)
        SizedBox(
          height: 250,
          width: 250,
          child: PrettyQrView.data(
            data: deepLink,
            decoration: const PrettyQrDecoration(
              shape: PrettyQrSmoothSymbol(color: Colors.black, roundFactor: 0),
              quietZone: PrettyQrQuietZone.pixels(20),
              background: Colors.white,
            ),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Row(
            spacing: 10,
            children: [
              Icon(Icons.qr_code_2_rounded, color: Theme.of(context).colorScheme.outline),
              Expanded(child: Text(context.tr('share.too_big'))),
            ],
          ),
        ),
      const SizedBox(height: 10),
      TextButton.icon(
        onPressed: () => _sendFile(context, payload),
        icon: const Icon(Icons.insert_drive_file_rounded),
        label: Text(context.tr('share.send_file')),
      ),
      if (fits) SheetHint(context.tr('share.qr_hint')),
    ],
  );
}

Future<void> _sendFile(BuildContext context, SharePayload payload) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/${payload.kind.name}.json');
  await file.writeAsString(jsonEncode(payload.items));
  if (!context.mounted) return;
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: context.tr('share.message.${payload.kind.name}')),
  );
}
