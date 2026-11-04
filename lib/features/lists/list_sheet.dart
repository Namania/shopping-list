import 'package:flutter/material.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// What the user chose in the list sheet.
sealed class ListSheetResult {}

/// Create a list, or rename it when the sheet was opened with a name.
final class NameList extends ListSheetResult {
  final String label;
  NameList(this.label);
}

/// Copy [source] under [label].
final class DuplicateList extends ListSheetResult {
  final ShoppingList source;
  final String label;
  DuplicateList(this.source, this.label);
}

/// Asks for a list's name in a bottom sheet. For a new list it also offers
/// ready-made names and copying one of [existing]; with [initial] it renames.
Future<ListSheetResult?> showListSheet(
  BuildContext context, {
  String? initial,
  List<ShoppingList> existing = const [],
}) {
  return showModalBottomSheet<ListSheetResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ListForm(initial: initial, existing: existing),
  );
}

/// Ready-made list names in the current language, minus those already used.
List<String> listSuggestions(BuildContext context, Iterable<String> taken) {
  final used = taken.map((t) => t.toLowerCase()).toSet();
  return context.l10n.listsSuggestions.split('|').where((s) => !used.contains(s.toLowerCase())).toList();
}

class _ListForm extends StatefulWidget {
  final String? initial;
  final List<ShoppingList> existing;

  const _ListForm({this.initial, required this.existing});

  @override
  State<_ListForm> createState() => _ListFormState();
}

class _ListFormState extends State<_ListForm> {
  late final _label = TextEditingController(text: widget.initial);

  @override
  void initState() {
    super.initState();
    _label.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  String get _name => _label.text.trim();

  void _submit([String? label]) {
    final name = label ?? _name;
    if (name.isEmpty) return;
    Navigator.pop<ListSheetResult>(context, NameList(name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = TextTheme.of(context);
    final renaming = widget.initial != null;
    final suggestions = renaming
        ? const <String>[]
        : listSuggestions(context, widget.existing.map((l) => l.label));

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Text(
                renaming ? l10n.listsFormEditTitle : l10n.listsAdd,
                style: text.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: _label,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(hintText: l10n.listsFormLabelHint),
              ),
              if (suggestions.isNotEmpty) ...[
                Text(l10n.listsIdeas, style: text.labelLarge!.copyWith(fontWeight: FontWeight.w600)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final suggestion in suggestions)
                      ActionChip(label: Text(suggestion), onPressed: () => _submit(suggestion)),
                  ],
                ),
              ],
              if (!renaming && widget.existing.isNotEmpty) ...[
                Text(l10n.listsDuplicateFrom, style: text.labelLarge!.copyWith(fontWeight: FontWeight.w600)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final list in widget.existing)
                      ActionChip(
                        avatar: const Icon(Icons.content_copy_rounded, size: 16),
                        label: Text(list.label),
                        onPressed: () => Navigator.pop<ListSheetResult>(
                          context,
                          DuplicateList(list, _name.isEmpty ? l10n.listsCopyOf(list.label) : _name),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: _name.isEmpty ? null : _submit,
                      child: Text(renaming ? l10n.commonSave : l10n.commonAdd),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
