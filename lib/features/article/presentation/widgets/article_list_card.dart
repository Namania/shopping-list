import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/utils/delete_alert_dialog.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';

class ArticleListCard extends StatelessWidget {
  final ArticleListModel articleList;

  const ArticleListCard({super.key, required this.articleList});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: GlobalKey(),
        onDismissed: (direction) => {},
        confirmDismiss: (direction) async {
          return await DeleteAlertDialog.dialog(
            context,
            'article',
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
        child: GestureDetector(
          onTap: () => context.push<void>("/article", extra: articleList),
          child: ListTile(
            title: Text(
              articleList.label,
              style: TextTheme.of(
                context,
              ).bodyLarge!.apply(color: Theme.of(context).colorScheme.primary),
            ),
            leading: Icon(Icons.list_rounded),
          ),
        ),
      ),
    );
  }
}
