import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/collection_page.dart';
import 'package:shopping_list/core/ui/empty_state.dart';
import 'package:shopping_list/core/ui/movable_list.dart';
import 'package:shopping_list/core/ui/options_menu.dart';
import 'package:shopping_list/core/ui/page_header.dart';
import 'package:shopping_list/features/cards/card_strip.dart';
import 'package:shopping_list/features/categories/uncategorized.dart';
import 'package:shopping_list/features/lists/list_actions.dart';
import 'package:shopping_list/features/lists/list_cards.dart';
import 'package:shopping_list/features/lists/list_sheet.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/sharing/import_sheet.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:shopping_list/features/sharing/share_sheet.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// The lists, the finished ones at the bottom ready to start over. A long
/// press on any of them lifts it to reorder.
class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  /// Local order while a drop is saved, so the list does not jump back.
  List<ShoppingList>? _pending;

  static bool _complete(ShoppingList list) => list.articles.isNotEmpty && list.articles.every((a) => a.done);

  void _onAction(CollectionAction action) {
    switch (action) {
      case CollectionAction.share:
        final none = uncategorized(context);
        final lists = context.read<ListsCubit>().state;
        showShareSheet(
          context,
          SharePayload(ShareKind.lists, [for (final l in lists) l.toMap(uncategorized: none)]),
          what: context.l10n.shareWhatLists(lists.length),
          text: lists.map(listAsText).join('\n\n'),
        );
      case CollectionAction.import:
        showImportSheet(context);
      case CollectionAction.move:
      case CollectionAction.delete:
        break;
    }
  }

  /// Moves an item inside one section and saves the new overall order:
  /// unfinished lists first, finished ones after.
  void _reorder(List<ShoppingList> active, List<ShoppingList> finished, bool inFinished, int from, int to) {
    final section = [...(inFinished ? finished : active)];
    section.insert(to, section.removeAt(from));
    final order = inFinished ? [...active, ...section] : [...section, ...finished];
    setState(() => _pending = order);
    context.read<ListsCubit>().setOrder(order.map((l) => l.id).toList()).whenComplete(() {
      if (mounted) setState(() => _pending = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lists = _pending ?? context.watch<ListsCubit>().state;
    final active = lists.where((l) => !_complete(l)).toList();
    final finished = lists.where(_complete).toList();
    final calculator = context.watch<SettingsCubit>().state.calculatorEnabled;
    final left = lists.fold(0, (sum, l) => sum + l.articles.where((a) => !a.done).length);
    final subtitle = [
      l10n.listsLeft(left),
      if (calculator) formatAmount(context, context.watch<PricesCubit>().total(null)),
    ].join(' · ');

    Widget section(List<ShoppingList> items, {required bool inFinished}) => SliverReorderableList(
      itemCount: items.length,
      onReorderItem: (from, to) => _reorder(active, finished, inFinished, from, to),
      proxyDecorator: (child, index, animation) => Material(
        elevation: 8,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: child,
      ),
      itemBuilder: (context, index) {
        final list = items[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(list.id),
          index: index,
          child: ListRow(list: list),
        );
      },
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: l10n.listsTitle,
              subtitle: lists.isEmpty ? null : subtitle,
              actions: [
                OptionsMenu<CollectionAction>(
                  options: [
                    for (final action in [CollectionAction.share, CollectionAction.import])
                      MenuOption(action, icon: action.icon, label: action.label(l10n)),
                  ],
                  onSelected: _onAction,
                ),
              ],
            ),
            Expanded(
              child: lists.isEmpty
                  ? _EmptyLists(onPick: (label) => createNamed(context, label))
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                          sliver: SliverList.list(children: const [CardStrip()]),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: section(active, inFinished: false),
                        ),
                        if (finished.isNotEmpty) ...[
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                l10n.listsFinished.toUpperCase(),
                                style: TextTheme.of(context).labelMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: section(finished, inFinished: true),
                          ),
                        ],
                        SliverPadding(padding: EdgeInsets.only(bottom: MovableList.padding.bottom)),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: AddButton(label: l10n.listsAdd, onPressed: () => createList(context)),
    );
  }
}

/// No list yet: say so warmly and offer ready-made lists in one tap.
class _EmptyLists extends StatelessWidget {
  final ValueChanged<String> onPick;

  const _EmptyLists({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: MovableList.padding,
      children: [
        EmptyState(icon: Icons.checklist_rounded, text: context.l10n.listsEmpty),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final suggestion in listSuggestions(context, const []))
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: Text(suggestion),
                onPressed: () => onPick(suggestion),
              ),
          ],
        ),
      ],
    );
  }
}
