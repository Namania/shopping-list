import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/collection_page.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/movable_list.dart';
import 'package:shopping_list/core/ui/options_menu.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/categories/uncategorized.dart';
import 'package:shopping_list/features/lists/article.dart';
import 'package:shopping_list/features/lists/article_form_dialog.dart';
import 'package:shopping_list/features/lists/article_tile.dart';
import 'package:shopping_list/features/lists/link_card_dialog.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/lists/shopping_list.dart';
import 'package:shopping_list/features/prices/amount_button.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:shopping_list/features/sharing/share_sheet.dart';

enum _ListAction { share, linkCard, unlinkCard, delete }

/// The articles of one list, grouped by category.
class ListPage extends StatelessWidget {
  final String listId;

  const ListPage({super.key, required this.listId});

  Future<void> _addArticle(BuildContext context, ShoppingList list) async {
    final input = await showArticleFormDialog(context);
    if (input == null || !context.mounted) return;
    final added = await context.read<ListsCubit>().addArticle(
      listId: list.id,
      label: input.label,
      category: input.category,
    );
    if (!added && context.mounted) showAppSnackBar(context, context.tr('list.exists', args: [input.label]));
  }

  Future<void> _linkCard(BuildContext context, ShoppingList list) async {
    final cards = context.read<CardsCubit>().state;
    if (cards.isEmpty) {
      showAppSnackBar(context, context.tr('lists.no_cards'));
      return;
    }
    final card = await showLinkCardDialog(context, cards: cards);
    if (card == null || !context.mounted) return;
    await context.read<ListsCubit>().update(list.copyWith(cardId: card.id));
  }

  Future<void> _clear(BuildContext context, ShoppingList list) async {
    final onlyDone = await showChoiceDialog<bool?>(
      context,
      message: context.tr('list.confirm_clear'),
      choices: [
        Choice(context.tr('common.no'), null, primary: false),
        Choice(context.tr('list.clear_done_only'), true),
        Choice(context.tr('common.yes'), false),
      ],
    );
    if (onlyDone == null || !context.mounted) return;
    await context.read<ListsCubit>().clear(list.id, onlyDone: onlyDone);
  }

  void _onAction(BuildContext context, ShoppingList list, _ListAction action) {
    switch (action) {
      case _ListAction.share:
        showShareSheet(
          context,
          SharePayload(ShareKind.lists, [list.toMap(uncategorized: uncategorized(context))]),
        );
      case _ListAction.linkCard:
        _linkCard(context, list);
      case _ListAction.unlinkCard:
        context.read<ListsCubit>().update(list.copyWith(clearCard: true));
      case _ListAction.delete:
        _clear(context, list);
    }
  }

  /// Articles in category order, each category preceded by a header.
  List<Widget> _grouped(BuildContext context, List<Article> articles) {
    final categories = [...context.watch<CategoriesCubit>().state];
    final none = uncategorized(context);
    final first = context.watch<SettingsCubit>().state.uncategorizedFirst;
    categories.insert(first ? 0 : categories.length, none);

    return [
      for (final category in categories)
        ...switch (articles.where((a) => (a.category ?? none) == category).toList()) {
          [] => const <Widget>[],
          final group => [
            _CategoryHeader(category),
            for (final article in group) ArticleTile(key: ValueKey(article.id), article: article),
          ],
        },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<ListsCubit>().byId(listId);
    if (list == null) {
      // Deleted while open.
      WidgetsBinding.instance.addPostFrameCallback((_) => context.mounted ? context.go('/lists') : null);
      return const Scaffold();
    }
    final calculator = context.watch<SettingsCubit>().state.calculatorEnabled;
    final cardAction =
        list.cardId == null
            ? MenuOption(_ListAction.linkCard, icon: Icons.add_rounded, label: context.tr('common.link'))
            : MenuOption(
              _ListAction.unlinkCard,
              icon: Icons.remove_rounded,
              label: context.tr('common.unlink'),
            );
    final children = _grouped(context, list.articles);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.only(left: 10), child: BackButton()),
        title: Text(list.label),
        actions: [
          if (calculator) AmountButton(listId: list.id),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: OptionsMenu<_ListAction>(
              options: [
                MenuOption(_ListAction.share, icon: Icons.share_rounded, label: context.tr('common.share')),
                cardAction,
                MenuOption(
                  _ListAction.delete,
                  icon: Icons.delete_rounded,
                  label: context.tr('common.delete'),
                ),
              ],
              onSelected: (action) => _onAction(context, list, action),
            ),
          ),
        ],
      ),
      body:
          children.isEmpty
              ? Center(child: Text(context.tr('list.empty')))
              : ListView(padding: MovableList.padding, children: children),
      floatingActionButton: AddButton(
        label: context.tr('list.add'),
        onPressed: () => _addArticle(context, list),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final Category category;

  const _CategoryHeader(this.category);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 50),
    child: Column(
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Text(category.label, style: TextTheme.of(context).titleLarge),
        ),
        const Divider(indent: 10, endIndent: 10),
      ],
    ),
  );
}
