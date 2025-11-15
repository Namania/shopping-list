import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/shared/cubit/setting_enable_calculator.dart';
import 'package:shopping_list/core/shared/widget/custom_bottom_modal.dart';
import 'package:shopping_list/core/utils/delete_alert_dialog.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/calculator/presentation/widgets/display_amount.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';

class ArticleListCard extends StatelessWidget {
  final ArticleListModel articleList;
  final Function removeCategory;
  final bool movableMode;

  const ArticleListCard({
    super.key,
    required this.articleList,
    required this.removeCategory,
    required this.movableMode,
  });

  void deleteList(BuildContext context) {
    context.read<ArticleBloc>().add(RemoveListEvent(articleList: articleList));
    removeCategory(articleList);
  }

  void editArticle(BuildContext context, ArticleListModel articleList) async {
    final labelController = TextEditingController();
    labelController.text = articleList.label;

    String? response = await showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(context.tr('articles.alert.edit.title')),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'articles.alert.add.placeholder.label',
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: Text(context.tr('article.alert.edit.action.cancel')),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      labelController.text != ""
                          ? '{"label": "${labelController.text}"}'
                          : "",
                    ),
                child: Text(context.tr('article.alert.edit.action.update')),
              ),
            ],
          ),
    );

    try {
      if (response != null && response != '') {
        Map<String, dynamic> data =
            json.decode(response) as Map<String, dynamic>;
        if (context.mounted) {
          context.read<ArticleBloc>().add(
            UpdateListEvent(
              articleList: articleList,
              label: data["label"],
              card: articleList.card,
            ),
          );
        }
      }
    } on FormatException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('core.error'),
              style: TextTheme.of(context).labelLarge,
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            duration: Durations.extralong4,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculator = context.read<SettingEnableCalculator>().isEnabled();
    List<Widget> leftChildren = [
      Text(articleList.label, style: TextTheme.of(context).titleLarge),
    ];
    List<Widget> rightChildren = [
      Text(context.plural('articles.count', articleList.articles.length)),
    ];
    if (articleList.card != "") {
      leftChildren.add(
        IconButton.outlined(
          color: Theme.of(context).colorScheme.tertiary,
          iconSize: 20,
          style: ButtonStyle(
            side: WidgetStatePropertyAll(
              BorderSide(color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
          onPressed: () {
            List<CardModel> cards =
                context
                    .read<CardBloc>()
                    .getAllCard()
                    .where((c) => c.id == articleList.card)
                    .toList();
            if (cards.isNotEmpty) {
              CardModel card = cards.first;
              CustomBottomModal.modal(
                context,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      card.label,
                      style: TextTheme.of(context).titleLarge,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(30),
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: card.code,
                      drawText: false,
                    ),
                  ),
                ],
              );
            }
          },
          icon: Icon(Icons.credit_card_rounded),
        ),
      );
    }
    if (calculator) {
      rightChildren.add(
        DisplayAmount(idList: articleList.id, articles: articleList.articles),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: GlobalKey(),
        onDismissed:
            (direction) => {
              {deleteList(context)},
            },
        confirmDismiss: (direction) async {
          return await DeleteAlertDialog.dialog(
            context,
            'articles',
            description: false,
          );
        },
        background: Container(
          color: Color(0xff93000a),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 5,
              children: [
                Icon(Icons.delete_rounded, color: Colors.white),
                Text(
                  context.tr('articles.delete'),
                  style: TextTheme.of(
                    context,
                  ).bodyLarge!.apply(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        secondaryBackground: Container(
          color: Color(0xff93000a),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 5,
              children: [
                Text(
                  context.tr('articles.delete'),
                  style: TextTheme.of(
                    context,
                  ).bodyLarge!.apply(color: Colors.white),
                ),
                Icon(Icons.delete_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
        child: GestureDetector(
          onLongPress: () {
            editArticle(context, articleList);
          },
          onTap: () => context.push<void>("/article", extra: articleList),
          child: ListTile(
            leading: movableMode ? Icon(Icons.drag_handle_rounded) : null,
            title: Container(
              padding: EdgeInsetsDirectional.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: leftChildren,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: rightChildren,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
