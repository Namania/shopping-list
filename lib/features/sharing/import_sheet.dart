import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/scanner/barcode_scanner_page.dart';
import 'package:shopping_list/core/ui/app_bottom_sheet.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/core/utils/json_file.dart';
import 'package:shopping_list/features/backup/restore_points.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/sharing/data_importer.dart';
import 'package:shopping_list/features/sharing/import_bundle.dart';
import 'package:shopping_list/features/sharing/import_preview_sheet.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// The one way in for anything shared or backed up: a QR code, a file or a
/// copied link. What it holds is always previewed before it is added.
Future<void> showImportSheet(BuildContext context) {
  final l10n = context.l10n;
  return showOptionSheet<void>(
    context,
    title: l10n.importTitle,
    subtitle: l10n.importSubtitle,
    options: [
      SheetOption(
        icon: Icons.qr_code_scanner_rounded,
        title: l10n.importScan,
        subtitle: l10n.importScanHint,
        onTap: () => _from(context, _scan),
      ),
      SheetOption(
        icon: Icons.file_open_outlined,
        title: l10n.importFile,
        subtitle: l10n.importFileHint,
        onTap: () => _from(context, _pickFile),
      ),
      SheetOption(
        icon: Icons.content_paste_rounded,
        title: l10n.importPaste,
        subtitle: l10n.importPasteHint,
        onTap: () => _from(context, _paste),
      ),
    ],
  );
}

/// Reads a source and closes the sheet; [read] returns `null` when the user
/// backed out and throws a [FormatException] when the source is not valid.
Future<void> _from(BuildContext context, Future<ImportBundle?> Function(BuildContext) read) async {
  final ImportBundle? bundle;
  try {
    bundle = await read(context);
  } on FormatException {
    if (context.mounted) showAppSnackBar(context, context.l10n.shareInvalid);
    return;
  }
  if (bundle == null || !context.mounted) return;
  Navigator.pop(context);
  await importBundle(context, bundle);
}

Future<ImportBundle?> _scan(BuildContext context) async {
  final scanned = await scanCode(context, qr: true);
  if (scanned == null) return null;
  return ImportBundle.fromLink(scanned.value) ?? (throw const FormatException('Not a share link'));
}

Future<ImportBundle?> _pickFile(BuildContext context) async {
  final decoded = await pickJsonFile();
  return decoded == null ? null : ImportBundle.fromJson(decoded);
}

Future<ImportBundle?> _paste(BuildContext context) async {
  final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
  return readImport(text) ?? (throw const FormatException('Nothing to import'));
}

/// Reads a share link or the content of a file, `null` when it is neither.
ImportBundle? readImport(String text) {
  final link = ImportBundle.fromLink(text);
  if (link != null) return link;
  try {
    return ImportBundle.fromJson(jsonDecode(text));
  } on FormatException {
    return null;
  }
}

/// Previews [bundle], then adds or restores it. A restore point is taken
/// first, so the import can be undone from the message that follows.
Future<void> importBundle(BuildContext context, ImportBundle bundle) async {
  final l10n = context.l10n;
  if (bundle.isEmpty) {
    showAppSnackBar(context, l10n.importEmpty);
    return;
  }
  final choice = await showImportPreview(context, bundle);
  if (choice == null || !context.mounted) return;

  final importer = context.read<DataImporter>();
  final points = context.read<RestorePoints>();
  final settings = context.read<SettingsCubit>();
  final previousSettings = settings.state;
  try {
    final point = await points.take(RestorePointReason.beforeImport);
    switch (choice) {
      case AddSelected(:final selection):
        await importer.add(selection);
      case ReplaceAll():
        final restored = await importer.replaceWith(bundle);
        if (restored != null) await settings.replace(restored);
    }
    if (!context.mounted) return;
    showUndoSnackBar(
      context,
      message: choice is ReplaceAll ? l10n.importRestored : l10n.importDone,
      onUndo: () async {
        if (point != null) await points.restore(point, saveCurrent: false);
        await settings.replace(previousSettings);
      },
    );
  } on TypeError {
    if (context.mounted) showAppSnackBar(context, l10n.shareInvalid);
  } on DatabaseException {
    if (context.mounted) showAppSnackBar(context, l10n.shareInvalid);
  }
}
