import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/utils/delete_alert_dialog.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';

class ArticleListCard extends StatelessWidget {
  final ArticleListModel articleList;

  const ArticleListCard({super.key, required this.articleList});
  
  void deleteList(BuildContext context) {
    context.read<ArticleBloc>().add(
      RemoveListEvent(articleList: articleList),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: GlobalKey(),
        onDismissed: (direction) => {
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
          onTap: () => context.push<void>("/article", extra: articleList),
          child: ListTile(
            title: Container(
              padding: EdgeInsetsDirectional.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text(
                        articleList.label,
                        style: TextTheme.of(context).titleLarge,
                      ),
                      // IconButton.outlined(
                      //   color: Theme.of(context).colorScheme.tertiary,
                      //   iconSize: 20,
                      //   style: ButtonStyle(
                      //     side: WidgetStatePropertyAll(
                      //       BorderSide(
                      //         color: Theme.of(context).colorScheme.tertiary,
                      //       ),
                      //     ),
                      //   ),
                      //   onPressed: () {},
                      //   icon: Icon(Icons.credit_card_rounded),
                      // ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        context.plural(
                          'articles.count',
                          articleList.articles.length,
                        ),
                      ),
                    ],
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
