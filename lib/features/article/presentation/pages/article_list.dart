import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/features/article/presentation/widgets/article_card.dart';

class ArticleList extends StatelessWidget {
  const ArticleList({super.key});

  void handleDelete(BuildContext context) async {
    bool? res = await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Text(context.tr('article.alert.confirm.title')),
            content: Text(context.tr('article.alert.confirm.description.all')),
            actions: <Widget>[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(context.tr('article.alert.confirm.action.no')),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(context.tr('article.alert.confirm.action.selected')),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(context.tr('article.alert.confirm.action.yes')),
                ),
              ),
            ],
          ),
    );
    if (res != null && context.mounted) {
      context.read<ArticleBloc>().add(ClearEvent(
        allArticle: res
      ));
    }
  }

  void handleAdd(BuildContext context) async {
    final labelController = TextEditingController();
    final quantityController = TextEditingController();

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
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'article.alert.add.placeholder.quantity',
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
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
                          ? '{"label": "${labelController.text}", "quantity": ${quantityController.text == "" ? 1 : quantityController.text}, "done": false}'
                          : "",
                    ),
                child: Text(context.tr('article.alert.add.action.add')),
              ),
            ],
          ),
    );

    try {
      if (response == null || response == '') {
        throw FormatException();
      }
      Map<String, dynamic> data = json.decode(response) as Map<String, dynamic>;
      if (context.mounted) {
        context.read<ArticleBloc>().add(
          AddArticleEvent(article: ArticleModel.fromMap(data)),
        );
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
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            onPressed: () {
              context.go("/");
            },
            icon: Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: Text(context.tr('core.card.article.title')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () async {
                handleDelete(context);
              },
              icon: Icon(Icons.delete),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (BuildContext context, ArticleState state) {
          switch (state) {
            case ArticleSuccess _:
              return state.articles.isEmpty
                  ? Center(child: (Text(context.tr('article.empty'))))
                  : SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListView.builder(
                          padding: EdgeInsets.only(bottom: 60),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.articles.length,
                          itemBuilder: (context, index) {
                            return ArticleCard(article: state.articles[index]);
                          },
                        ),
                      ],
                    ),
                  );
            case ArticleFailure _:
              return Text(context.tr('core.error'));
            default:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), SizedBox(height: 50)],
                ),
              );
          }
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
