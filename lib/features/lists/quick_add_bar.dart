import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/features/lists/article_form_dialog.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';

/// A field pinned under the list: type, press Enter, the article is added
/// and the field stays open for the next one. The tune button opens the full
/// form to pick a category.
class QuickAddBar extends StatefulWidget {
  final ShoppingList list;

  const QuickAddBar({super.key, required this.list});

  @override
  State<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends State<QuickAddBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final label = _controller.text.trim();
    if (label.isEmpty) return;
    final added = await context.read<ListsCubit>().addArticle(listId: widget.list.id, label: label);
    if (!mounted) return;
    if (added) {
      HapticFeedback.lightImpact();
      _controller.clear();
    } else {
      showAppSnackBar(context, context.l10n.listExists(label));
    }
    _focus.requestFocus();
  }

  Future<void> _openForm() async {
    final input = await showArticleFormDialog(
      context,
      initial: _controller.text.trim().isEmpty ? null : (label: _controller.text.trim(), category: null),
    );
    if (input == null || !mounted) return;
    final added = await context.read<ListsCubit>().addArticle(
      listId: widget.list.id,
      label: input.label,
      category: input.category,
    );
    if (!mounted) return;
    if (added) {
      _controller.clear();
    } else {
      showAppSnackBar(context, context.l10n.listExists(input.label));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final empty = _controller.text.trim().isEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          spacing: 8,
          children: [
            IconButton(
              tooltip: context.l10n.listMoreOptions,
              onPressed: _openForm,
              icon: Icon(Icons.tune_rounded, color: colors.outline),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: context.l10n.listQuickAdd,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            AnimatedScale(
              scale: empty ? 0.85 : 1,
              duration: const Duration(milliseconds: 150),
              child: IconButton.filled(
                tooltip: context.l10n.commonAdd,
                style: IconButton.styleFrom(
                  backgroundColor: colors.secondary,
                  foregroundColor: colors.onSecondary,
                  disabledBackgroundColor: colors.surfaceContainerHighest,
                  minimumSize: const Size(48, 48),
                ),
                onPressed: empty ? null : _submit,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
