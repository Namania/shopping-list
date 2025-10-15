import 'dart:collection';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/shared/cubit/setting_default_category_position.dart';
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

class ArticleList extends StatefulWidget {
  const ArticleList({super.key});

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
      context.read<ArticleBloc>().add(ClearEvent(allArticle: res));
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
                          ? '{"label": "${labelController.text}", "category": ${categories.where((c) => c.label == categoryEntriesValue).first.toJson()}, "done": false}'
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
            AddArticleEvent(article: ArticleModel.fromMap(data)),
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
    HandleMenuButton.click(
      context: context,
      action: value,
      data: context.read<ArticleBloc>().getAllArticle(),
      deepLinkAction: "importArticles",
      import: (data) {
        context.read<ArticleBloc>().add(
          ArticleImportEvent(
            json: data,
            defaultCategory: CategoryModel(
              label: context.mounted ? context.tr('category.default') : "Other",
              color:
                  context.mounted
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black,
            ),
          ),
        );
      },
      onDelete: () {
        handleDelete(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<CategoryBloc>().add(CategoryGetAllEvent());
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: BackButton(
            onPressed: () {
              context.go("/");
            },
          ),
        ),
        title: Text(context.tr('core.card.article.title')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              onSelected: (value) => handleClick(context, value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surfaceContainer,
              itemBuilder: (context) {
                final choices = [
                  {'label': 'share', 'icon': Icons.share_rounded},
                  {'label': 'import', 'icon': Icons.download_rounded},
                  {'label': 'delete', 'icon': Icons.delete},
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
        builder: (BuildContext context, ArticleState state) {
          final List<ArticleModel> data =
              context.read<ArticleBloc>().getAllArticle();
          final List<CategoryModel> categories =
              context.read<CategoryBloc>().getAllCategory();

          final List<ArticleModel> articles = [];
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
            articles.addAll(data.where((a) => a.category == category));
          }
          if (articles.isEmpty) {
            return Center(child: (Text(context.tr('article.empty'))));
          }
          return ListView.builder(
            padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 65),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return index == 0 ||
                      articles[index - 1].category.label !=
                          articles[index].category.label
                  ? ArticleCategory(article: articles[index])
                  : ArticleCard(article: articles[index]);
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
