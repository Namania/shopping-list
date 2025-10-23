import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../article/data/models/article_model.dart';
import '../../data/models/Calculator_model.dart';

class CalculatorCard extends StatelessWidget {
  final CalculatorModel model;
  final ArticleModel article;

  const CalculatorCard({super.key, required this.model, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Badge(
          padding: EdgeInsets.all(3),
          backgroundColor: article.category.color,
          label: const SizedBox(height: 10),
        ),
        title: Text(
          article.label,
          style: TextTheme.of(context).bodyLarge!.apply(
            color: Theme.of(context).colorScheme.primary,
            decorationColor: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: Text(context.tr('calculator.success', args: [(model.price / 100).toString()])),
      ),
    );
  }
}
