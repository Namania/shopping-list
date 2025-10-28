import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/calculator/presentation/bloc/calculator_bloc.dart';

import '../../../../core/utils/delete_alert_dialog.dart';
import '../../../article/data/models/article_model.dart';
import '../../../category/data/models/category_model.dart';
import '../../data/models/calculator_model.dart';

// ignore: must_be_immutable
class CalculatorCard extends StatelessWidget {
  final CalculatorModel model;
  ArticleModel? article;
  bool hasArticle = true;

  CalculatorCard(this.article, {super.key, required this.model});

  void deleteArticle(
    BuildContext context,
    ArticleModel article,
  ) {
    context.read<CalculatorBloc>().add(
      hasArticle
          ? CalculatorResetWithEvent(articles: [article])
          : CalculatorResetWithoutArticleEvent(articles: [article.id]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (article == null) {
      hasArticle = false;
      article = ArticleModel(
        id: model.idArticle,
        label: context.tr('calculator.withoutArticle'),
        category: CategoryModel(
          label: "",
          color: Theme.of(context).colorScheme.primary,
        ),
        done: true,
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: GlobalKey(),
        onDismissed:
            (direction) => {
              {deleteArticle(context, article!)},
            },
        confirmDismiss: (direction) async {
          return await DeleteAlertDialog.dialog(
            context,
            'calculator',
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
                  context.tr('article.delete'),
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
                  context.tr('article.delete'),
                  style: TextTheme.of(
                    context,
                  ).bodyLarge!.apply(color: Colors.white),
                ),
                Icon(Icons.delete_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
        child: ListTile(
          leading: Badge(
            padding: EdgeInsets.all(3),
            backgroundColor: article!.category.color,
            label: const SizedBox(height: 10),
          ),
          title: Text(
            article!.label,
            style: TextTheme.of(context).bodyLarge!.apply(
              color: Theme.of(context).colorScheme.primary,
              decorationColor: Theme.of(context).colorScheme.outline,
            ),
          ),
          trailing: Text(
            context.tr(
              'calculator.success',
              args: [(model.price / 100).toString()],
            ),
          ),
        ),
      ),
    );
  }
}
