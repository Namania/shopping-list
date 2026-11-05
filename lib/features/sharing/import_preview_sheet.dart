import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list/core/utils/colors.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/features/sharing/import_bundle.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// What the user chose in the import preview.
sealed class ImportChoice {}

/// Add the chosen items to the current data.
final class AddSelected extends ImportChoice {
  final ImportBundle selection;
  AddSelected(this.selection);
}

/// Replace the current data with the whole backup.
final class ReplaceAll extends ImportChoice {}

/// Shows what [bundle] holds before anything is written: every list, card
/// and category, ticked, to untick what to leave out. A backup can also
/// replace everything. `null` when the user backs out.
Future<ImportChoice?> showImportPreview(BuildContext context, ImportBundle bundle) {
  return showModalBottomSheet<ImportChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _ImportPreview(bundle: bundle),
  );
}

class _ImportPreview extends StatefulWidget {
  final ImportBundle bundle;

  const _ImportPreview({required this.bundle});

  @override
  State<_ImportPreview> createState() => _ImportPreviewState();
}

class _ImportPreviewState extends State<_ImportPreview> {
  late final _lists = {for (var i = 0; i < widget.bundle.lists.length; i++) i};
  late final _cards = {for (var i = 0; i < widget.bundle.cards.length; i++) i};
  late final _categories = {for (var i = 0; i < widget.bundle.categories.length; i++) i};

  int get _selected => _lists.length + _cards.length + _categories.length;

  void _add() => Navigator.pop<ImportChoice>(
    context,
    AddSelected(widget.bundle.only(lists: _lists, cards: _cards, categories: _categories)),
  );

  Future<void> _replace() async {
    final l10n = context.l10n;
    final confirmed = await showChoiceDialog<bool>(
      context,
      message: l10n.importReplaceConfirm,
      icon: Icons.restore_rounded,
      choices: [
        Choice(l10n.importReplaceConfirmButton, true, destructive: true),
        Choice(l10n.commonCancel, false, primary: false),
      ],
    );
    if (confirmed == true && mounted) Navigator.pop<ImportChoice>(context, ReplaceAll());
  }

  void _toggle(Set<int> set, int index, bool? on) =>
      setState(() => on == true ? set.add(index) : set.remove(index));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = TextTheme.of(context);
    final colors = Theme.of(context).colorScheme;
    final bundle = widget.bundle;
    final date = bundle.createdAt;
    final title = !bundle.isBackup
        ? l10n.importReceived
        : date == null
        ? l10n.importBackup
        : l10n.importBackupOf(
            DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date.toLocal()),
            DateFormat.Hm(Localizations.localeOf(context).toString()).format(date.toLocal()),
          );

    Widget section(String label, Set<int> set, int total) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: text.labelMedium!.copyWith(
                color: colors.outline,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              if (set.length == total) {
                set.clear();
              } else {
                set.addAll([for (var i = 0; i < total; i++) i]);
              }
            }),
            child: Text(set.length == total ? l10n.importNone : l10n.importAll),
          ),
        ],
      ),
    );

    Widget item(Set<int> set, int index, String label, String? detail, Widget leading) => CheckboxListTile(
      value: set.contains(index),
      onChanged: (on) => _toggle(set, index, on),
      secondary: leading,
      title: Text(label, style: text.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
      subtitle: detail == null ? null : Text(detail, style: text.bodySmall!.copyWith(color: colors.outline)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(title, style: text.titleLarge!.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          [
                            if (bundle.lists.isNotEmpty) l10n.shareWhatLists(bundle.lists.length),
                            if (bundle.cards.isNotEmpty) l10n.shareWhatCards(bundle.cards.length),
                            if (bundle.categories.isNotEmpty)
                              l10n.shareWhatCategories(bundle.categories.length),
                          ].join(' · '),
                          style: text.bodyMedium!.copyWith(color: colors.outline),
                        ),
                      ],
                    ),
                  ),
                  if (bundle.lists.isNotEmpty) ...[
                    section(l10n.navLists, _lists, bundle.lists.length),
                    for (final (i, list) in bundle.lists.indexed)
                      item(
                        _lists,
                        i,
                        list['label'] as String,
                        l10n.listsCount((list['articles'] as List<dynamic>?)?.length ?? 0),
                        const Icon(Icons.checklist_rounded),
                      ),
                  ],
                  if (bundle.cards.isNotEmpty) ...[
                    section(l10n.navCards, _cards, bundle.cards.length),
                    for (final (i, card) in bundle.cards.indexed)
                      item(
                        _cards,
                        i,
                        card['label'] as String,
                        null,
                        Icon(
                          Icons.credit_card_rounded,
                          color: visibleColor(context, opaqueColor(card['color'] as int?)),
                        ),
                      ),
                  ],
                  if (bundle.categories.isNotEmpty) ...[
                    section(l10n.importCategories, _categories, bundle.categories.length),
                    for (final (i, category) in bundle.categories.indexed)
                      item(
                        _categories,
                        i,
                        category['label'] as String,
                        null,
                        Icon(
                          Icons.circle,
                          size: 18,
                          color: visibleColor(context, opaqueColor(category['color'] as int?)),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 4,
                children: [
                  FilledButton(
                    onPressed: _selected == 0 ? null : _add,
                    child: Text(l10n.importAdd(_selected)),
                  ),
                  if (bundle.isBackup)
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: colors.error),
                      onPressed: _replace,
                      child: Text(l10n.importReplace),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
