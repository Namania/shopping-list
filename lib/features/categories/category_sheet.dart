import 'package:flutter/material.dart';
import 'package:shopping_list/core/ui/color_swatch_picker.dart';
import 'package:shopping_list/core/utils/strings.dart';
import 'package:shopping_list/features/categories/category_badge.dart';
import 'package:shopping_list/l10n/l10n.dart';

typedef CategoryInput = ({String label, Color color});

/// What the user chose in the category sheet.
sealed class CategorySheetResult {}

/// Save these values (add or edit).
final class SaveCategory extends CategorySheetResult {
  final CategoryInput input;
  SaveCategory(this.input);
}

/// Delete the category being edited.
final class DeleteCategory extends CategorySheetResult {}

/// Asks for a category's name and colour in a bottom sheet, with a live
/// preview. Pass [initial] to edit a category: the sheet then also offers to
/// delete it. `null` when the sheet is dismissed.
Future<CategorySheetResult?> showCategorySheet(BuildContext context, {CategoryInput? initial}) {
  return showModalBottomSheet<CategorySheetResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _CategoryForm(initial: initial),
  );
}

class _CategoryForm extends StatefulWidget {
  final CategoryInput? initial;

  const _CategoryForm({this.initial});

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  late final _label = TextEditingController(text: widget.initial?.label);
  late Color _color = widget.initial?.color ?? swatchColors[5];

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

  void _submit() {
    if (_name.isEmpty) return;
    Navigator.pop<CategorySheetResult>(context, SaveCategory((label: capitalize(_name), color: _color)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = TextTheme.of(context);
    final editing = widget.initial != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      // No glow at the top and bottom edges when the form is pulled past its
      // ends: the sheet itself already follows the finger.
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(
                editing ? l10n.categoriesFormEditTitle : l10n.categoriesFormAddTitle,
                style: text.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              // Live preview: the category as it will appear in the lists.
              Row(
                spacing: 14,
                children: [
                  CategoryBadge(label: _name, color: _color, size: 48),
                  Expanded(
                    child: Text(
                      _name.isEmpty ? l10n.categoriesFormNameHint : capitalize(_name),
                      style: text.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _name.isEmpty ? Theme.of(context).colorScheme.outline : null,
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _label,
                autofocus: !editing,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(hintText: l10n.categoriesFormNameHint),
              ),
              Text(l10n.colorTitle, style: text.labelLarge!.copyWith(fontWeight: FontWeight.w600)),
              ColorSwatchPicker(value: _color, onChanged: (color) => setState(() => _color = color)),
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
                      child: Text(editing ? l10n.commonSave : l10n.commonAdd),
                    ),
                  ),
                ],
              ),
              if (editing)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () => Navigator.pop<CategorySheetResult>(context, DeleteCategory()),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.categoriesDelete),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
