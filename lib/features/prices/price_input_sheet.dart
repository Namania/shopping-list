import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// What the user chose in the price sheet.
sealed class PriceInput {}

final class SetPrice extends PriceInput {
  final int cents;
  SetPrice(this.cents);
}

/// Delete the amount being edited.
final class DeletePrice extends PriceInput {}

/// Asks for an amount in a bottom sheet. The keyboard's "OK" and the
/// validate button both close it and apply the amount; a tap outside keeps
/// what was typed too, so nothing is lost. [title] names what the amount is
/// for; [initialCents] edits an existing amount and also offers to delete it.
/// `null` when nothing was entered.
Future<PriceInput?> showPriceSheet(BuildContext context, {String? title, int? initialCents}) async {
  int? typed = initialCents;
  final result = await showModalBottomSheet<PriceInput>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _PriceForm(initialCents: initialCents, title: title, onChanged: (cents) => typed = cents),
  );
  if (result != null) return result;
  return typed == null || typed == initialCents ? null : SetPrice(typed!);
}

int? _parseCents(String text) {
  final amount = double.tryParse(text.replaceAll(',', '.'));
  return amount == null ? null : (amount * 100).round();
}

class _PriceForm extends StatefulWidget {
  final int? initialCents;
  final String? title;

  /// What is typed, in cents, so a tap outside the sheet still keeps it.
  final ValueChanged<int?> onChanged;

  const _PriceForm({this.initialCents, this.title, required this.onChanged});

  @override
  State<_PriceForm> createState() => _PriceFormState();
}

class _PriceFormState extends State<_PriceForm> {
  late final _amount = TextEditingController(
    text: widget.initialCents == null ? '' : (widget.initialCents! / 100).toStringAsFixed(2),
  );

  @override
  void initState() {
    super.initState();
    _amount.addListener(() {
      widget.onChanged(_cents);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  bool get _editing => widget.initialCents != null;

  int? get _cents => _parseCents(_amount.text);

  void _submit() {
    final cents = _cents;
    if (cents == null) return;
    HapticFeedback.lightImpact();
    Navigator.pop<PriceInput>(context, SetPrice(cents));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final text = TextTheme.of(context);
    // "{amount} €" or "${amount}": the currency goes where the language puts it.
    final [prefix, suffix] = l10n.calculatorAmount('\u0000').split('\u0000').map((s) => s.trim()).toList();
    final amountStyle = text.displaySmall!.copyWith(
      fontWeight: FontWeight.w700,
      color: colors.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final currencyStyle = amountStyle.copyWith(color: colors.outline, fontWeight: FontWeight.w500);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(
                widget.title ?? l10n.calculatorAddButton,
                textAlign: TextAlign.center,
                style: text.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _amount,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: amountStyle,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [_AmountFormatter()],
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: NumberFormat.decimalPatternDigits(
                      locale: Localizations.localeOf(context).toString(),
                      decimalDigits: 2,
                    ).format(0),
                    hintStyle: amountStyle.copyWith(color: colors.outlineVariant),
                    prefixText: prefix.isEmpty ? null : '$prefix ',
                    prefixStyle: currencyStyle,
                    suffixText: suffix.isEmpty ? null : ' $suffix',
                    suffixStyle: currencyStyle,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onChanged(null);
                        Navigator.pop(context);
                      },
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: _cents == null ? null : _submit,
                      child: Text(l10n.commonValidate),
                    ),
                  ),
                ],
              ),
              if (_editing)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.error,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () => Navigator.pop<PriceInput>(context, DeletePrice()),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.calculatorDelete),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accepts digits with at most two decimals; an edit that would break that
/// is refused rather than clearing the field.
class _AmountFormatter extends TextInputFormatter {
  static final _valid = RegExp(r'^\d*([.,]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      _valid.hasMatch(newValue.text) ? newValue : oldValue;
}
