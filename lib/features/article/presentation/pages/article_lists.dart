import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/article/presentation/widgets/article_list_card.dart';

class ArticleLists extends StatefulWidget {
  const ArticleLists({super.key});

  @override
  State<ArticleLists> createState() => _ArticleListsState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _ArticleListsState extends State<ArticleLists> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: BackButton(
            onPressed: () {
              context.go("/");
            },
          ),
        ),
        title: Text(context.tr('core.card.article.title')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              onSelected: (value) {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surfaceContainer,
              itemBuilder: (context) {
                final choices = [
                  {'label': 'share', 'icon': Icons.share_rounded},
                  {'label': 'import', 'icon': Icons.download_rounded},
                  {'label': 'delete', 'icon': Icons.delete},
                ];

                return choices.map((choice) {
                  return PopupMenuItem<String>(
                    padding: EdgeInsets.only(left: 20, right: 10),
                    value: choice['label'] as String,
                    child: Row(
                      children: [
                        Icon(
                          choice['icon'] as IconData,
                          size: 20,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.tr("articles.options.${choice['label']}"),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        buildWhen: (previous, state) {
          return state is ArticleSuccess;
        },
        builder: (BuildContext context, ArticleState state) {
          final List<ArticleListModel> articleLists =
              context.read<ArticleBloc>().getAllArticle();
          if (articleLists.isEmpty) {
            return Center(child: (Text(context.tr('articles.empty'))));
          }
          return ListView.builder(
            padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 65),
            itemCount: articleLists.length,
            itemBuilder: (context, index) {
              return ArticleListCard(articleList: articleLists[index]);
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          onPressed: () {},
          label: Text(context.tr('articles.add')),
          icon: Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
