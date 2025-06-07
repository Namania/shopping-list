import 'dart:convert';

import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/features/article/presentation/widget/article_card.dart';

class ArticleList extends StatelessWidget {
  const ArticleList({super.key});

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
        title: const Text("Ma liste"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () async {
                final labelController = TextEditingController();
                final quantityController = TextEditingController();

                String? response = await showDialog<String>(
                  context: context,
                  builder:
                      (BuildContext context) => AlertDialog(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        title: const Text('Ajouter un article'),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              TextField(
                                controller: labelController,
                                decoration: InputDecoration(
                                  hintText: "Entrez le nom de l'article",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.name,
                              ),
                              TextField(
                                controller: quantityController,
                                decoration: InputDecoration(
                                  hintText: "Entrez sa quantité",
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
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed:
                                () => Navigator.pop(
                                  context,
                                  labelController.text != ""
                                      ? '{"label": "${labelController.text}", "quantity": ${quantityController.text == "" ? 1 : quantityController.text}, "done": false}'
                                      : "",
                                ),
                            child: const Text('Ajouter'),
                          ),
                        ],
                      ),
                );

                try {
                  if (response == null || response == '') {
                    throw FormatException();
                  }
                  Map<String, dynamic> data =
                      json.decode(response) as Map<String, dynamic>;
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
                          "Une erreur est survenue !",
                          style: TextTheme.of(context).labelLarge,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        duration: Durations.extralong4,
                      ),
                    );
                  }
                }
              },
              icon: Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (BuildContext context, ArticleState state) {
          switch (state) {
            case ArticleSuccess _:
              return state.articles.isEmpty
                  ? Center(child: (Text("Aucun article dans la liste !")))
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
                            return ArticleCard(
                              article: state.articles[index],
                            );
                          },
                        ),
                      ],
                    ),
                  );
            case ArticleFailure _:
              return Text("Une erreur est survenue !");
            default:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 50,)
                  ],
                )
              );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          onPressed: () async {
            bool res = await showDialog(
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
            if (res && context.mounted) {
              context.read<ArticleBloc>().add(ClearEvent());
            }
          },
          label: Text("Tout supprimer"),
          icon: Icon(Icons.delete),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
