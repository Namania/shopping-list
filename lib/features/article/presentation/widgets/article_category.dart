import 'package:flutter/material.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/presentation/widgets/article_card.dart';

class ArticleCategory extends StatelessWidget {
  final ArticleModel article;

  const ArticleCategory({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(article.category.label, style: TextTheme.of(context).titleLarge),
          ),
          const Divider(indent: 10, endIndent: 10),
          ArticleCard(article: article),
        ],
      ),
    );
  }
}
