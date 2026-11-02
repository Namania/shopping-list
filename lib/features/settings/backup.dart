import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/ui/app_bottom_sheet.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/utils/json_file.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/uncategorized.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/sharing/data_importer.dart';

/// Offers to save every piece of data to a JSON file, or to restore one.
Future<void> showBackupSheet(BuildContext context) {
  return showAppBottomSheet<void>(
    context,
    children: [
      Row(
        spacing: 10,
        children: [
          SheetActionTile(
            icon: Icons.download_rounded,
            label: context.tr('settings.backup.download'),
            onTap: () => _finish(context, _export(context), 'download'),
          ),
          SheetActionTile(
            icon: Icons.upload_rounded,
            label: context.tr('settings.backup.upload'),
            onTap: () => _finish(context, _import(context), 'upload'),
          ),
        ],
      ),
    ],
  );
}

/// Shows the outcome of [task] (`null` = cancelled) and closes the sheet.
Future<void> _finish(BuildContext context, Future<bool?> task, String action) async {
  final success = await task;
  if (!context.mounted || success == null) return;
  Navigator.pop(context);
  showAppSnackBar(context, context.tr('settings.backup.${action}_${success ? 'success' : 'failure'}'));
}

Future<bool?> _export(BuildContext context) async {
  final none = uncategorized(context);
  final data = {
    'articles': context.read<ListsCubit>().state.map((l) => l.toMap(uncategorized: none)).toList(),
    'cards': context.read<CardsCubit>().state.map((c) => c.toMap()).toList(),
    'categories': context.read<CategoriesCubit>().state.map((c) => c.toMap()).toList(),
    'settings': {...context.read<SettingsCubit>().state.toMap(), 'lang': context.locale.languageCode},
  };
  final saved = await FilePicker.saveFile(
    fileName: 'shopping-list_${DateTime.now().toIso8601String()}.json',
    mimeType: 'application/json',
    bytes: Uint8List.fromList(utf8.encode(jsonEncode(data))),
  );
  return saved != null;
}

Future<bool?> _import(BuildContext context) async {
  final replace = await showChoiceDialog<bool?>(
    context,
    message: context.tr('settings.backup.restore_mode'),
    choices: [
      Choice(context.tr('common.cancel'), null, primary: false),
      Choice(context.tr('settings.backup.merge'), false),
      Choice(context.tr('settings.backup.replace'), true),
    ],
  );
  if (replace == null || !context.mounted) return null;

  final BackupSettings restored;
  try {
    final data = await pickJsonFile();
    if (data == null) return null;
    if (!context.mounted) return null;
    restored = await context.read<DataImporter>().importBackup(
      data as Map<String, dynamic>,
      replace: replace,
    );
  } on FormatException {
    return false;
  } on TypeError {
    return false;
  } on DatabaseException {
    return false;
  }
  if (!context.mounted) return null;

  if (restored.settings != null) {
    await context.read<SettingsCubit>().replace(restored.settings!);
  }
  final lang = restored.lang;
  if (lang != null && context.mounted && context.supportedLocales.contains(Locale(lang))) {
    await context.setLocale(Locale(lang));
  }
  return true;
}
