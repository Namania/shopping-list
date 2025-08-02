import 'dart:collection';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/shared/pages/settings.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final int index;

  const ArticleCard({super.key, required this.article, required this.index});

  void toogleArticleDoneState(BuildContext context) {
    context.read<ArticleBloc>().add(ToogleArticleDoneStateEvent(index: index));
  }

  void deleteArticle(BuildContext context) {
    context.read<ArticleBloc>().add(RemoveArticleEvent(index: index));
  }

  void editArticle(BuildContext context, ArticleModel article) async {
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
    String categoryEntriesValue =
        categories.contains(article.category)
            ? article.category.label
            : otherCategory.label;

    labelController.text = article.label;

    String? response = await showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(context.tr('article.alert.edit.title')),
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
                        'article.alert.edit.placeholder.name',
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
                child: Text(context.tr('article.alert.edit.action.cancel')),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      labelController.text != ""
                          ? '{"label": "${labelController.text}", "category": ${categories.where((c) => c.label == categoryEntriesValue).first.toJson()}}'
                          : "",
                    ),
                child: Text(context.tr('article.alert.edit.action.update')),
              ),
            ],
          ),
    );

    try {
      if (response != null && response != '') {
        Map<String, dynamic> data = json.decode(response) as Map<String, dynamic>;
        if (context.mounted) {
          context.read<ArticleBloc>().add(
            UpdateArticleEvent(
              article: article,
              label: data["label"],
              category: CategoryModel.fromMap(data["category"]),
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: GlobalKey(),
        onDismissed:
            (direction) => {
              {deleteArticle(context)},
            },
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder:
                (BuildContext context) => AlertDialog(
                  title: Text(context.tr('article.alert.confirm.title')),
                  content: Text(
                    context.tr('article.alert.confirm.description.one'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        context.tr('article.alert.confirm.action.no'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        context.tr('article.alert.confirm.action.yes'),
                      ),
                    ),
                  ],
                ),
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
                Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                ),
                Text(
                  context.tr('article.delete'),
                  style: TextTheme.of(context).bodyLarge!.apply(
                    color: Colors.white,
                  ),
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
                  context.tr('article.delete'),
                  style: TextTheme.of(context).bodyLarge!.apply(
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        child: GestureDetector(
          onLongPress: () {
            editArticle(context, article);
          },
          child: CheckboxListTile(
            activeColor: Theme.of(context).colorScheme.tertiary,
            secondary: Badge(
              padding: EdgeInsets.all(3),
              backgroundColor:
                  article.done
                      ? Theme.of(context).colorScheme.outline
                      : article.category.color,
              label: const SizedBox(height: 10),
            ),
            title: Text(
              article.label,
              style: TextTheme.of(context).bodyLarge!.apply(
                color:
                    article.done
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.primary,
                decoration:
                    article.done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                decorationColor: Theme.of(context).colorScheme.outline,
              ),
            ),
            value: article.done,
            onChanged: (bool? value) {
              toogleArticleDoneState(context);
            },
          ),
        ),
      ),
    );
  }
}
