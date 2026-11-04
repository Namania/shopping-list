import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopping_list/core/ui/app_bottom_sheet.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/features/backup/data_dump.dart';
import 'package:shopping_list/features/backup/restore_points.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/sharing/import_bundle.dart';
import 'package:shopping_list/features/sharing/import_sheet.dart';
import 'package:shopping_list/core/utils/json_file.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// Everything in one file, sent where the user wants it or saved on the
/// phone, and the way back from such a file.
Future<void> showBackupSheet(BuildContext context) {
  final l10n = context.l10n;
  return showOptionSheet<void>(
    context,
    title: l10n.backupTitle,
    subtitle: l10n.backupSubtitle,
    options: [
      SheetOption(
        icon: Icons.send_rounded,
        title: l10n.backupSend,
        subtitle: l10n.backupSendHint,
        onTap: () => _send(context),
      ),
      SheetOption(
        icon: Icons.save_alt_rounded,
        title: l10n.backupSave,
        subtitle: l10n.backupSaveHint,
        onTap: () => _save(context),
      ),
      SheetOption(
        icon: Icons.settings_backup_restore_rounded,
        title: l10n.backupRestore,
        subtitle: l10n.backupRestoreHint,
        onTap: () => _restore(context),
      ),
    ],
  );
}

String _fileName(DateTime date) => 'shopping-list_${DateFormat('yyyy-MM-dd_HH-mm').format(date)}.json';

Future<String> _backupJson(BuildContext context, DateTime date) async =>
    TransferFile.backup(await DataDump.read(context.read<RestorePoints>().db), date);

Future<void> _send(BuildContext context) async {
  final date = DateTime.now();
  final json = await _backupJson(context, date);
  final file = File('${(await getTemporaryDirectory()).path}/${_fileName(date)}');
  await file.writeAsString(json);
  if (!context.mounted) return;
  Navigator.pop(context);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/json')]));
}

Future<void> _save(BuildContext context) async {
  final l10n = context.l10n;
  final date = DateTime.now();
  final json = await _backupJson(context, date);
  final saved = await FilePicker.saveFile(
    fileName: _fileName(date),
    mimeType: 'application/json',
    bytes: Uint8List.fromList(utf8.encode(json)),
  );
  if (saved == null || !context.mounted) return;
  Navigator.pop(context);
  showAppSnackBar(context, l10n.backupSaved);
}

Future<void> _restore(BuildContext context) async {
  final ImportBundle bundle;
  try {
    final decoded = await pickJsonFile();
    if (decoded == null) return;
    bundle = ImportBundle.fromJson(decoded);
  } on FormatException {
    if (context.mounted) showAppSnackBar(context, context.l10n.shareInvalid);
    return;
  }
  if (!context.mounted) return;
  Navigator.pop(context);
  await importBundle(context, bundle);
}

/// The copies the app keeps on its own, newest first; going back to one is
/// itself undoable.
Future<void> showRestorePointsSheet(BuildContext context) async {
  final points = context.read<RestorePoints>();
  final all = await points.all();
  if (!context.mounted) return;
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toString();
  String when(DateTime date) =>
      '${DateFormat.MMMMEEEEd(locale).format(date)} · ${DateFormat.Hm(locale).format(date)}';

  final chosen = await showOptionSheet<RestorePoint>(
    context,
    title: l10n.restorePointsTitle,
    subtitle: all.isEmpty ? l10n.restorePointsEmpty : l10n.restorePointsSubtitle,
    options: [
      for (final point in all)
        SheetOption(
          icon: switch (point.reason) {
            RestorePointReason.daily => Icons.today_rounded,
            RestorePointReason.beforeImport => Icons.file_download_outlined,
            RestorePointReason.beforeRestore => Icons.history_rounded,
          },
          title: when(point.date),
          subtitle: switch (point.reason) {
            RestorePointReason.daily => l10n.restorePointDaily,
            RestorePointReason.beforeImport => l10n.restorePointBeforeImport,
            RestorePointReason.beforeRestore => l10n.restorePointBeforeRestore,
          },
          onTap: () => Navigator.pop(context, point),
        ),
    ],
  );
  if (chosen == null || !context.mounted) return;

  final confirmed = await showChoiceDialog<bool>(
    context,
    message: l10n.restorePointConfirm(when(chosen.date)),
    icon: Icons.history_rounded,
    choices: [
      Choice(l10n.restorePointRestore, true, destructive: true),
      Choice(l10n.commonCancel, false, primary: false),
    ],
  );
  if (confirmed != true || !context.mounted) return;
  final settings = context.read<SettingsCubit>();
  final restored = await points.restore(chosen);
  if (restored != null) await settings.replace(restored);
  if (context.mounted) showAppSnackBar(context, l10n.restorePointDone);
}
