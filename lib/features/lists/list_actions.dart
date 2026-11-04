import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/features/lists/list_sheet.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// Opens the "new list" sheet, creates or copies the list and opens it.
Future<void> createList(BuildContext context) async {
  final cubit = context.read<ListsCubit>();
  final result = await showListSheet(context, existing: cubit.state);
  if (result == null || !context.mounted) return;
  await createFromSheet(context, result);
}

/// Applies a [ListSheetResult] of the "new list" sheet.
Future<void> createFromSheet(BuildContext context, ListSheetResult result) async {
  final cubit = context.read<ListsCubit>();
  switch (result) {
    case NameList(:final label):
      if (!await cubit.add(label)) {
        if (context.mounted) showAppSnackBar(context, context.l10n.listsExists(label));
        return;
      }
      final created = cubit.state.where((l) => l.label == label).firstOrNull;
      if (created != null && context.mounted) context.push('/lists/${created.id}');
    case DuplicateList(:final source, :final label):
      final id = await cubit.duplicate(source.id, label);
      if (id != null && context.mounted) context.push('/lists/$id');
  }
}

/// Creates a list straight from a suggested name.
Future<void> createNamed(BuildContext context, String label) => createFromSheet(context, NameList(label));

Future<void> renameList(BuildContext context, ShoppingList list) async {
  final result = await showListSheet(context, initial: list.label);
  if (result is! NameList || !context.mounted) return;
  await context.read<ListsCubit>().update(list.copyWith(label: result.label));
}

/// Unchecks every article, to shop the same list again.
Future<void> restartList(BuildContext context, ShoppingList list) async {
  HapticFeedback.lightImpact();
  await context.read<ListsCubit>().restart(list.id);
  if (context.mounted) showAppSnackBar(context, context.l10n.listsRestarted(list.label));
}

Future<void> duplicateList(BuildContext context, ShoppingList list) async {
  final id = await context.read<ListsCubit>().duplicate(list.id, context.l10n.listsCopyOf(list.label));
  if (id != null && context.mounted) context.push('/lists/$id');
}

/// Asks, deletes the list and offers to undo. Returns `true` when deleted.
Future<bool> deleteList(BuildContext context, ShoppingList list) async {
  if (!await confirmDelete(context, message: context.l10n.listsConfirmDelete) || !context.mounted) {
    return false;
  }
  final cubit = context.read<ListsCubit>();
  final message = context.l10n.commonDeleted(list.label);
  final deleted = await cubit.remove(list.id);
  if (deleted != null && context.mounted) {
    showUndoSnackBar(context, message: message, onUndo: () => cubit.restore(deleted));
  }
  return deleted != null;
}

/// A list as a message anyone can read, without the app: what is left to
/// buy first, then what is already in the cart.
String listAsText(ShoppingList list) => [
  '🛒 ${list.label}',
  for (final article in list.articles.where((a) => !a.done)) '☐ ${article.label}',
  for (final article in list.articles.where((a) => a.done)) '☑ ${article.label}',
].join('\n');
