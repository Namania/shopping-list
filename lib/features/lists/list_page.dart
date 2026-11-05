import 'package:shopping_list/core/ui/page_body.dart';
import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/empty_state.dart';
import 'package:shopping_list/core/ui/options_menu.dart';
import 'package:shopping_list/core/ui/page_header.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/categories/uncategorized.dart';
import 'package:shopping_list/features/lists/article.dart';
import 'package:shopping_list/features/lists/article_tile.dart';
import 'package:shopping_list/features/lists/link_card_dialog.dart';
import 'package:shopping_list/features/lists/list_actions.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/lists/quick_add_bar.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:shopping_list/features/sharing/share_sheet.dart';

enum _ListAction { rename, duplicate, restart, share, linkCard, unlinkCard, clear, delete }

/// One list: its progress, the articles still to buy grouped by category,
/// the ones already in the cart folded at the bottom, and a field to add
/// articles without leaving the page.
class ListPage extends StatefulWidget {
  final String listId;

  const ListPage({super.key, required this.listId});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  bool _showDone = false;

  Future<void> _linkCard(ShoppingList list) async {
    final cards = context.read<CardsCubit>().state;
    if (cards.isEmpty) {
      showAppSnackBar(context, context.l10n.listsNoCards);
      return;
    }
    final card = await showLinkCardDialog(context, cards: cards);
    if (card == null || !mounted) return;
    await context.read<ListsCubit>().update(list.copyWith(cardId: card.id));
  }

  Future<void> _clear(ShoppingList list) async {
    final onlyDone = await showChoiceDialog<bool?>(
      context,
      message: context.l10n.listConfirmClear,
      icon: Icons.delete_sweep_outlined,
      choices: [
        Choice(context.l10n.listClearDoneOnly, true),
        Choice(context.l10n.listClearAll, false, destructive: true),
        Choice(context.l10n.commonCancel, null, primary: false),
      ],
    );
    if (onlyDone == null || !mounted) return;
    await context.read<ListsCubit>().clear(list.id, onlyDone: onlyDone);
  }

  void _onAction(ShoppingList list, _ListAction action) {
    switch (action) {
      case _ListAction.rename:
        renameList(context, list);
      case _ListAction.duplicate:
        duplicateList(context, list);
      case _ListAction.restart:
        restartList(context, list);
      case _ListAction.share:
        showShareSheet(
          context,
          SharePayload(ShareKind.lists, [list.toMap(uncategorized: uncategorized(context))]),
          what: list.label,
          text: listAsText(list),
        );
      case _ListAction.linkCard:
        _linkCard(list);
      case _ListAction.unlinkCard:
        context.read<ListsCubit>().update(list.copyWith(clearCard: true));
      case _ListAction.clear:
        _clear(list);
      case _ListAction.delete:
        deleteList(context, list);
    }
  }

  /// The articles still to buy, by category in the user's category order.
  List<(Category, List<Article>)> _groups(List<Article> todo) {
    final categories = [...context.watch<CategoriesCubit>().state];
    final none = uncategorized(context);
    final first = context.watch<SettingsCubit>().state.uncategorizedFirst;
    categories.insert(first ? 0 : categories.length, none);
    return [
      for (final category in categories)
        if (todo.where((a) => (a.category ?? none) == category).toList() case final group
            when group.isNotEmpty)
          (category, group),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<ListsCubit>().byId(widget.listId);
    if (list == null) {
      // Deleted while open.
      WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? context.go('/lists') : null);
      return const Scaffold();
    }
    final colors = Theme.of(context).colorScheme;
    final calculator = context.watch<SettingsCubit>().state.calculatorEnabled;
    final card = context.watch<CardsCubit>().byId(list.cardId);
    final todo = list.articles.where((a) => !a.done).toList();
    final done = list.articles.where((a) => a.done).toList();
    final total = list.articles.length;

    return Scaffold(
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: list.label,
              showBack: true,
              actions: [
                if (card != null)
                  IconButton(
                    tooltip: card.label,
                    onPressed: () => context.push('/cards/${card.id}'),
                    icon: Icon(Icons.credit_card_rounded, color: card.color),
                  ),
                OptionsMenu<_ListAction>(
                  options: [
                    MenuOption(_ListAction.rename, icon: Icons.edit_outlined, label: context.l10n.listRename),
                    MenuOption(
                      _ListAction.duplicate,
                      icon: Icons.content_copy_rounded,
                      label: context.l10n.listDuplicate,
                    ),
                    if (done.isNotEmpty)
                      MenuOption(
                        _ListAction.restart,
                        icon: Icons.replay_rounded,
                        label: context.l10n.listsRestart,
                      ),
                    MenuOption(
                      _ListAction.share,
                      icon: Icons.ios_share_rounded,
                      label: context.l10n.commonShare,
                    ),
                    list.cardId == null
                        ? MenuOption(
                            _ListAction.linkCard,
                            icon: Icons.add_card_rounded,
                            label: context.l10n.commonLink,
                          )
                        : MenuOption(
                            _ListAction.unlinkCard,
                            icon: Icons.credit_card_off_rounded,
                            label: context.l10n.commonUnlink,
                          ),
                    if (total > 0)
                      MenuOption(
                        _ListAction.clear,
                        icon: Icons.delete_sweep_outlined,
                        label: context.l10n.listClear,
                      ),
                    MenuOption(
                      _ListAction.delete,
                      icon: Icons.delete_outline_rounded,
                      label: context.l10n.listDeleteList,
                    ),
                  ],
                  onSelected: (action) => _onAction(list, action),
                ),
              ],
            ),
            if (total > 0)
              _Progress(
                done: done.length,
                total: total,
                amount: calculator ? AmountButton(listId: list.id) : null,
              ),
            Expanded(
              child: total == 0
                  ? ListView(
                      children: [
                        EmptyState(icon: Icons.add_shopping_cart_rounded, text: context.l10n.listEmpty),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        for (final (category, articles) in _groups(todo)) ...[
                          _GroupHeader(category: category, count: articles.length),
                          _Group(
                            children: [
                              for (final a in articles) ArticleTile(key: ValueKey(a.id), article: a),
                            ],
                          ),
                        ],
                        if (todo.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              spacing: 8,
                              children: [
                                Icon(Icons.celebration_rounded, size: 36, color: colors.tertiary),
                                Text(
                                  context.l10n.listAllDone,
                                  style: TextTheme.of(context).titleMedium!.copyWith(color: colors.tertiary),
                                ),
                              ],
                            ),
                          ),
                        if (done.isNotEmpty) ...[
                          _DoneHeader(
                            count: done.length,
                            open: _showDone,
                            onTap: () => setState(() => _showDone = !_showDone),
                          ),
                          if (_showDone)
                            _Group(
                              children: [for (final a in done) ArticleTile(key: ValueKey(a.id), article: a)],
                            ),
                        ],
                      ],
                    ),
            ),
            QuickAddBar(list: list),
          ],
        ),
      ),
    );
  }
}

/// "5 / 14 in the cart", a progress bar and, with the calculator, the total.
class _Progress extends StatelessWidget {
  final int done;
  final int total;
  final Widget? amount;

  const _Progress({required this.done, required this.total, this.amount});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.listsProgress(done, total),
                  style: TextTheme.of(context).bodyMedium!.copyWith(
                    color: colors.outline,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              ?amount,
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: done / total),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 8),
            ),
          ),
        ],
      ),
    );
  }
}

/// The name of a category above its articles, with its colour.
class _GroupHeader extends StatelessWidget {
  final Category category;
  final int count;

  const _GroupHeader({required this.category, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: category.color, borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Text(
              category.label,
              style: TextTheme.of(context).titleSmall!.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text('$count', style: TextTheme.of(context).bodyMedium!.copyWith(color: colors.outline)),
        ],
      ),
    );
  }
}

/// Rows of one category in a single rounded card, separated by hairlines.
class _Group extends StatelessWidget {
  final List<Widget> children;

  const _Group({required this.children});

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) const Divider(indent: 56), children[i]],
      ],
    ),
  );
}

/// "In the cart (5)", tap to unfold the checked articles.
class _DoneHeader extends StatelessWidget {
  final int count;
  final bool open;
  final VoidCallback onTap;

  const _DoneHeader({required this.count, required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            spacing: 10,
            children: [
              Icon(Icons.shopping_basket_rounded, size: 18, color: colors.tertiary),
              Expanded(
                child: Text(
                  context.l10n.listInCart(count),
                  style: TextTheme.of(context).titleSmall!.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(Icons.expand_more_rounded, color: colors.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
