import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../article/data/models/article_model.dart';
import '../../../category/data/models/category_model.dart';
import '../../data/models/Calculator_model.dart';

// ignore: must_be_immutable
class CalculatorCard extends StatelessWidget {
  final CalculatorModel model;
  ArticleModel? article;

  CalculatorCard(this.article, {super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    article ??= ArticleModel(
      id: model.idArticle,
      label: context.tr('calculator.withoutArticle'),
      category: CategoryModel(
        label: "",
        color: Theme.of(context).colorScheme.primary,
      ),
      done: true,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
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
    );
  }
}
