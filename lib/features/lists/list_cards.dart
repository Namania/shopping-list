import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/ui/progress_ring.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/lists/list_actions.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// Shows a row can be moved: a long press anywhere lifts it.
class DragHint extends StatelessWidget {
  const DragHint({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.categoriesReorderHint,
    child: Icon(Icons.drag_indicator_rounded, color: Theme.of(context).colorScheme.outline),
  );
}

/// A list as a compact row: progress ring, name, what is left, total.
class ListRow extends StatelessWidget {
  final ShoppingList list;

  const ListRow({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = TextTheme.of(context);
    final l10n = context.l10n;
    final total = list.articles.length;
    final left = list.articles.where((a) => !a.done).length;
    final complete = total > 0 && left == 0;
    final card = context.watch<CardsCubit>().byId(list.cardId);
    final calculator = context.watch<SettingsCubit>().state.calculatorEnabled;

    return Card(
      child: InkWell(
        onTap: () => context.push('/lists/${list.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 14, 12),
          child: Row(
            spacing: 12,
            children: [
              const DragHint(),
              ProgressRing(done: total - left, total: total),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(list.label, style: text.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          complete
                              ? l10n.listsComplete
                              : (total == 0 ? l10n.listsCount(0) : l10n.listsLeft(left)),
                          style: text.bodySmall!.copyWith(color: complete ? colors.tertiary : colors.outline),
                        ),
                        if (card != null) _CardTag(label: card.label, color: card.color),
                      ],
                    ),
                  ],
                ),
              ),
              if (complete)
                TextButton(onPressed: () => restartList(context, list), child: Text(l10n.listsRestart))
              else if (calculator)
                Text(
                  formatAmount(context, context.watch<PricesCubit>().total(list.id)),
                  style: text.bodyMedium!.copyWith(color: colors.secondary, fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The store a list is for, as a small coloured tag.
class _CardTag extends StatelessWidget {
  final String label;
  final Color color;

  const _CardTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 5,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      ),
      Flexible(
        child: Text(label, style: TextTheme.of(context).bodySmall!.copyWith(fontWeight: FontWeight.w600)),
      ),
    ],
  );
}
