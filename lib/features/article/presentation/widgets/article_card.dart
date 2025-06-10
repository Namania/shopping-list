import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/article/domain/entities/article.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final int index;

  const ArticleCard({super.key, required this.article, required this.index});

  void toogleArticleDoneState(BuildContext context) {
    context.read<ArticleBloc>().add(
      ToogleArticleDoneStateEvent(
        index: index,
      ),
    );
  }

  void deleteArticle(BuildContext context) {
    context.read<ArticleBloc>().add(
      RemoveArticleEvent(
        index: index,
      ),
    );
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
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 5,
              children: [
                Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                Text(
                  context.tr('article.delete'),
                  style: TextTheme.of(context).bodyLarge!.apply(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        secondaryBackground: Container(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 5,
              children: [
                Text(
                  context.tr('article.delete'),
                  style: TextTheme.of(context).bodyLarge!.apply(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ],
            ),
          ),
        ),
        child: CheckboxListTile(
          activeColor: Theme.of(context).colorScheme.tertiary,
          secondary: Badge(
            padding: EdgeInsets.all(3),
            backgroundColor:
                article.done
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.primary,
            label: Text(article.quantity.toString()),
            textColor: Theme.of(context).colorScheme.onPrimary,
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
    );
  }
}
