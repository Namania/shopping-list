import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/scanner/barcode_scanner_page.dart';
import 'package:shopping_list/core/ui/app_bottom_sheet.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/utils/json_file.dart';
import 'package:shopping_list/features/sharing/data_importer.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';

/// Lets the user import a collection of [kind] by scanning a QR code or by
/// picking a JSON file.
Future<void> showImportSheet(BuildContext context, {required ShareKind kind}) {
  return showAppBottomSheet<void>(
    context,
    children: [
      Row(
        spacing: 10,
        children: [
          SheetActionTile(
            icon: Icons.qr_code_scanner_rounded,
            label: context.tr('share.scan'),
            onTap: () => _import(context, kind, _fromQrCode(context, kind)),
          ),
          SheetActionTile(
            icon: Icons.insert_drive_file_rounded,
            label: context.tr('share.pick_file'),
            onTap: () => _import(context, kind, _fromFile()),
          ),
        ],
      ),
    ],
  );
}

/// Items read from a source: `cancelled` when the user backed out, `items`
/// `null` when the source was not a valid share.
typedef _Source = ({bool cancelled, List<Map<String, dynamic>>? items});

const _Source _cancelled = (cancelled: true, items: null);
const _Source _invalid = (cancelled: false, items: null);

Future<void> _import(BuildContext context, ShareKind kind, Future<_Source> source) async {
  final (:cancelled, :items) = await source;
  if (cancelled || !context.mounted) return;
  if (items == null) {
    showAppSnackBar(context, context.tr('share.invalid'));
    return;
  }
  try {
    await context.read<DataImporter>().importShared(kind, items);
  } on TypeError {
    if (context.mounted) showAppSnackBar(context, context.tr('share.invalid'));
    return;
  } on DatabaseException {
    if (context.mounted) showAppSnackBar(context, context.tr('share.invalid'));
    return;
  }
  if (context.mounted) Navigator.pop(context);
}

Future<_Source> _fromQrCode(BuildContext context, ShareKind kind) async {
  final scanned = await scanCode(context, qr: true);
  if (scanned == null) return _cancelled;
  final uri = Uri.tryParse(scanned.value);
  if (uri == null || !SharePayload.isDeepLink(uri)) return _invalid;
  final payload = SharePayload.decode(uri.queryParameters['data']);
  return payload?.kind == kind ? (cancelled: false, items: payload!.items) : _invalid;
}

Future<_Source> _fromFile() async {
  try {
    final decoded = await pickJsonFile();
    if (decoded == null) return _cancelled;
    return (cancelled: false, items: (decoded as List<dynamic>).cast<Map<String, dynamic>>());
  } on FormatException {
    return _invalid;
  } on TypeError {
    return _invalid;
  }
}
