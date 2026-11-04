import 'package:flutter/material.dart';
import 'package:shopping_list/core/scanner/barcode_scanner_page.dart';
import 'package:shopping_list/core/ui/color_swatch_picker.dart';
import 'package:shopping_list/core/utils/strings.dart';
import 'package:shopping_list/features/cards/card_face.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// Values entered in the card form.
typedef CardInput = ({String label, String code, Color color, CardFormat format});

/// What the user chose in the card sheet.
sealed class CardSheetResult {}

/// Save these values (add or edit).
final class SaveCard extends CardSheetResult {
  final CardInput input;
  SaveCard(this.input);
}

/// Delete the card being edited.
final class DeleteCard extends CardSheetResult {}

/// Asks for a card's store, code, barcode format and colour in a bottom
/// sheet, with a live preview of the card. Scanning fills the code and its
/// format. Pass [initial] to edit a card: the sheet then also offers to
/// delete it. `null` when the sheet is dismissed.
Future<CardSheetResult?> showCardSheet(BuildContext context, {CardInput? initial}) {
  return showModalBottomSheet<CardSheetResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _CardForm(initial: initial),
  );
}

class _CardForm extends StatefulWidget {
  final CardInput? initial;

  const _CardForm({this.initial});

  @override
  State<_CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<_CardForm> {
  late final _label = TextEditingController(text: widget.initial?.label);
  late final _code = TextEditingController(text: widget.initial?.code);
  late CardFormat _format = widget.initial?.format ?? CardFormat.code128;
  late Color _color = widget.initial?.color ?? swatchColors[8];

  @override
  void initState() {
    super.initState();
    _label.addListener(() => setState(() {}));
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _label.dispose();
    _code.dispose();
    super.dispose();
  }

  String get _name => _label.text.trim();
  String get _number => _code.text.trim();
  bool get _valid => _name.isNotEmpty && _number.isNotEmpty;

  Future<void> _scan() async {
    final scanned = await scanCode(context, qr: false);
    if (scanned == null || !mounted) return;
    setState(() {
      _code.text = scanned.value;
      _format = CardFormat.fromScanner(scanned.format) ?? CardFormat.code128;
    });
  }

  void _submit() {
    if (!_valid) return;
    Navigator.pop<CardSheetResult>(
      context,
      SaveCard((label: capitalize(_name), code: _number, color: _color, format: _format)),
    );
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
            spacing: 14,
            children: [
              Text(
                editing ? l10n.cardsFormEditTitle : l10n.cardsFormAddTitle,
                style: text.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              // Live preview: the card as it will appear.
              CardFace(
                label: _name.isEmpty ? l10n.cardsFormNameHint : capitalize(_name),
                code: _number,
                color: _color,
                format: _format,
              ),
              TextField(
                controller: _label,
                autofocus: !editing,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: l10n.cardsFormNameHint),
              ),
              TextField(
                controller: _code,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: l10n.cardsFormCodeHint,
                  suffixIcon: IconButton(
                    tooltip: l10n.cardsScan,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    onPressed: _scan,
                  ),
                ),
              ),
              Text(l10n.cardsFormat, style: text.labelLarge!.copyWith(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final format in CardFormat.values)
                    ChoiceChip(
                      label: Text(format.label),
                      selected: format == _format,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _format = format),
                    ),
                ],
              ),
              if (_number.isNotEmpty && !_format.accepts(_number))
                Text(
                  l10n.cardsInvalidCode(_format.label),
                  style: text.bodySmall!.copyWith(color: Theme.of(context).colorScheme.error),
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
                      onPressed: _valid ? _submit : null,
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
                  onPressed: () => Navigator.pop<CardSheetResult>(context, DeleteCard()),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.cardsDelete),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
