import 'dart:collection';
import 'dart:convert';

import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shopping_list/core/shared/cubit/setting_default_category_position.dart';
import 'package:shopping_list/core/shared/cubit/setting_enable_calculator.dart';
import 'package:shopping_list/core/utils/delete_alert_dialog.dart';
import 'package:shopping_list/core/utils/handle_menu_button.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/article/presentation/widgets/article_card.dart';
import 'package:shopping_list/features/article/presentation/widgets/article_category.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';

import '../../../calculator/presentation/bloc/calculator_bloc.dart';
import '../../../calculator/presentation/widgets/display_amount.dart';

// ignore: must_be_immutable
class ArticleList extends StatefulWidget {
  ArticleListModel articleList;

  ArticleList({super.key, required this.articleList});

  @override
  State<ArticleList> createState() => _ArticleListState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _ArticleListState extends State<ArticleList> {
  void handleDelete(BuildContext context) async {
    bool? res = await DeleteAlertDialog.dialog(
      context,
      'article',
      description: true,
      hasSelection: true,
    );
    if (res != null && context.mounted) {
      context.read<ArticleBloc>().add(
        ClearEvent(id: widget.articleList.id, allArticle: res),
      );
      if (context.read<SettingEnableCalculator>().isEnabled()) {
        context.read<CalculatorBloc>().add(
          CalculatorResetWithEvent(articles: widget.articleList.articles),
        );
      }
    }
  }

  void handleAdd(BuildContext context) async {
    final labelController = TextEditingController();

    List<CategoryModel> categories =
        context.read<CategoryBloc>().getAllCategory();
    CategoryModel otherCategory = CategoryModel(
      label: context.tr('category.default'),
      color: Theme.of(context).colorScheme.primary,
    );
    categories.insert(0, otherCategory);
    List<MenuEntry> categoryEntries = UnmodifiableListView<MenuEntry>(
      categories.map<MenuEntry>(
        (CategoryModel c) => MenuEntry(
          value: c.label,
          labelWidget: Text(c.label),
          label: c.label,
        ),
      ),
    );
    String categoryEntriesValue = categories.first.label;

    Uuid uuid = Uuid();

    String? response = await showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(context.tr('article.alert.add.title')),
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
                        'article.alert.add.placeholder.name',
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  DropdownMenu<String>(
                    initialSelection: categoryEntriesValue,
                    onSelected: (String? value) {
                      categoryEntriesValue = value!;
                    },
                    dropdownMenuEntries: categoryEntries,
                    selectedTrailingIcon: Icon(Icons.arrow_drop_up_rounded),
                    trailingIcon: Icon(Icons.arrow_drop_down_rounded),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: Text(context.tr('article.alert.add.action.cancel')),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      labelController.text != ""
                          ? '{"id": "${uuid.v4()}","label": "${labelController.text}", "category": ${categories.where((c) => c.label == categoryEntriesValue).first.toJson()}, "done": false}'
                          : "",
                    ),
                child: Text(context.tr('article.alert.add.action.add')),
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
            AddArticleEvent(
              id: widget.articleList.id,
              article: ArticleModel.fromMap(data),
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

  void handleAddCard(BuildContext context) async {
    List<CardModel> cards = context.read<CardBloc>().getAllCard();
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('articles.emptyCards'),
            style: TextTheme.of(context).labelLarge,
          ),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          duration: Durations.extralong4,
        ),
      );
      return;
    }
    List<MenuEntry> cardsEntries = UnmodifiableListView<MenuEntry>(
      cards.map<MenuEntry>(
        (CardModel c) =>
            MenuEntry(value: c.id, labelWidget: Text(c.label), label: c.label),
      ),
    );
    String cardsEntriesValue = cards.first.id;
    String? response = await showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(context.tr('article.alert.addCard.title')),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double fieldWidth = constraints.maxWidth;
                      return DropdownMenuTheme(
                        data: DropdownMenuThemeData(
                          menuStyle: MenuStyle(
                            maximumSize: WidgetStatePropertyAll<Size>(
                              Size(fieldWidth, double.infinity),
                            ),
                            alignment: Alignment.bottomLeft,
                          ),
                        ),
                        child: DropdownMenu<String>(
                          width: fieldWidth,
                          initialSelection: cardsEntriesValue,
                          onSelected: (String? value) {
                            cardsEntriesValue = value!;
                          },
                          dropdownMenuEntries: cardsEntries,
                          selectedTrailingIcon: Icon(
                            Icons.arrow_drop_up_rounded,
                          ),
                          trailingIcon: Icon(Icons.arrow_drop_down_rounded),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: Text(context.tr('article.alert.addCard.action.cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, cardsEntriesValue),
                child: Text(context.tr('article.alert.addCard.action.add')),
              ),
            ],
          ),
    );

    try {
      if (response != null && response != '') {
        if (context.mounted) {
          context.read<ArticleBloc>().add(
            UpdateListEvent(
              articleList: widget.articleList,
              label: widget.articleList.label,
              card: response,
            ),
          );
          widget.articleList = ArticleListModel(
            id: widget.articleList.id,
            label: widget.articleList.label,
            card: response,
            articles: widget.articleList.articles,
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

  void handleClick(BuildContext context, String value) async {
    switch (value) {
      case 'cardAdd':
        handleAddCard(context);
        break;
      case 'cardRemove':
        context.read<ArticleBloc>().add(
          UpdateListEvent(
            articleList: widget.articleList,
            label: widget.articleList.label,
            card: "",
          ),
        );
        widget.articleList = ArticleListModel(
          id: widget.articleList.id,
          label: widget.articleList.label,
          card: "",
          articles: widget.articleList.articles,
        );
        break;
      default:
        HandleMenuButton.click(
          context: context,
          action: value,
          data: [
            context.read<ArticleBloc>().getAllArticle().singleWhere(
              (l) => l.id == widget.articleList.id,
            ),
          ],
          deepLinkAction: "importArticles",
          onDelete: () {
            handleDelete(context);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<ArticleBloc>().add(ArticleGetAllEvent());
    context.read<CategoryBloc>().add(CategoryGetAllEvent());
    context.read<CardBloc>().add(CardGetAllEvent());
    final calculator = context.read<SettingEnableCalculator>().isEnabled();
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: BackButton(),
        ),
        title: Text(widget.articleList.label),
        actions: [
          calculator
              ? DisplayAmount(
                specificId: true,
                idList: widget.articleList.id,
                articles: widget.articleList.articles,
              )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              onSelected: (value) => handleClick(context, value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surfaceContainer,
              itemBuilder: (context) {
                bool hasCard = widget.articleList.card != "";
                final choices = [
                  {'label': 'share', 'icon': Icons.share_rounded},
                  {
                    'label': hasCard ? 'cardRemove' : 'cardAdd',
                    'icon': hasCard ? Icons.remove_rounded : Icons.add_rounded,
                  },
                  {'label': 'delete', 'icon': Icons.delete_rounded},
                ];
                return choices.map((choice) {
                  return PopupMenuItem<String>(
                    padding: EdgeInsets.only(left: 20, right: 10),
                    value: choice['label'] as String,
                    child: Row(
                      children: [
                        Icon(
                          choice['icon'] as IconData,
                          size: 20,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.tr("article.options.${choice['label']}"),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        buildWhen: (previous, state) {
          return state is ArticleSuccess;
        },
        builder: (context, state) {
          final List<ArticleModel> articles =
              context
                  .read<ArticleBloc>()
                  .getAllArticle()
                  .singleWhere((l) => l.id == widget.articleList.id)
                  .articles;

          final List<CategoryModel> categories =
              context.read<CategoryBloc>().getAllCategory();

          final List<ArticleModel> data = [];
          categories.insert(
            context.read<SettingDefaultCategoryPosition>().getValue()
                ? 0
                : categories.length,
            CategoryModel(
              label: context.tr('category.default'),
              color: Theme.of(context).colorScheme.primary,
            ),
          );
          for (CategoryModel category in categories) {
            data.addAll(articles.where((a) => a.category == category));
          }

          return data.isEmpty
              ? Center(child: (Text(context.tr('article.empty'))))
              : ListView.builder(
                padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 65),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return index == 0 ||
                          data[index - 1].category.label !=
                              data[index].category.label
                      ? ArticleCategory(
                        articleListId: widget.articleList.id,
                        article: data[index],
                      )
                      : ArticleCard(
                        articleListId: widget.articleList.id,
                        article: data[index],
                      );
                },
              );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          onPressed: () {
            handleAdd(context);
          },
          label: Text(context.tr('article.add')),
          icon: Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
