import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/domain/entities/article.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  void toogleArticleDoneState(BuildContext context) {
    context.read<ArticleBloc>().add(
      ToogleArticleDoneStateEvent(
        article: ArticleModel.fromMap(<String, dynamic>{
          "label": article.label,
          "quantity": article.quantity,
          "done": article.done,
        }),
      ),
    );
  }

  void deleteArticle(BuildContext context) {
    context.read<ArticleBloc>().add(
      RemoveArticleEvent(
        article: ArticleModel.fromMap(<String, dynamic>{
          "label": article.label,
          "quantity": article.quantity,
          "done": article.done,
        }),
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
                  title: const Text("Confirmez"),
                  content: const Text("Voulez-vous vraiment le supprimer ?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Non'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Oui'),
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
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  "Supprimer",
                  style: TextTheme.of(context).bodyLarge!.apply(
                    color: Theme.of(context).colorScheme.primary,
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
                  "Supprimer",
                  style: TextTheme.of(context).bodyLarge!.apply(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.primary,
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
