import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/article/presentation/widgets/article_card.dart';

class ArticleList extends StatelessWidget {
  const ArticleList({super.key});

  void handleDelete(BuildContext context) async {
    bool? res = await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Text(context.tr('article.alert.confirm.title')),
            content: Text(context.tr('article.alert.confirm.description.all')),
            actions: <Widget>[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(context.tr('article.alert.confirm.action.no')),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    context.tr('article.alert.confirm.action.selected'),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(context.tr('article.alert.confirm.action.yes')),
                ),
              ),
            ],
          ),
    );
    if (res != null && context.mounted) {
      context.read<ArticleBloc>().add(ClearEvent(allArticle: res));
    }
  }

  void handleAdd(BuildContext context) async {
    final labelController = TextEditingController();
    final quantityController = TextEditingController();

    String? response = await showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(context.tr('article.alert.add.title')),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'article.alert.add.placeholder.name',
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'article.alert.add.placeholder.quantity',
                      ),
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
                child: Text(context.tr('article.alert.add.action.cancel')),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      labelController.text != ""
                          ? '{"label": "${labelController.text}", "quantity": ${quantityController.text == "" ? 1 : quantityController.text}, "done": false}'
                          : "",
                    ),
                child: Text(context.tr('article.alert.add.action.add')),
              ),
            ],
          ),
    );

    try {
      if (response == null || response == '') {
        throw FormatException();
      }
      Map<String, dynamic> data = json.decode(response) as Map<String, dynamic>;
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
              context.tr('core.error'),
              style: TextTheme.of(context).labelLarge,
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            duration: Durations.extralong4,
          ),
        );
      }
    }
  }

  
  Future<String> handleScaning(BuildContext context) async {
    String barcodeScanRes = '';
    try {
      String res = await FlutterBarcodeScanner.scanBarcode(
        "#ffffff",
        context.tr('card.cancel'),
        false,
        ScanMode.QR,
      );
      if (res != "-1") {
        barcodeScanRes = res;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du scan");
      }
    }
    return barcodeScanRes;
  }

  void handleClick(BuildContext context, String value) async {
    switch (value) {
      case 'export':
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 50,
                  children: <Widget>[
                    BlocBuilder<ArticleBloc, ArticleState>(
                      builder: (BuildContext context, ArticleState state) {
                        switch (state) {
                          case ArticleFailure _:
                            if (kDebugMode) {
                              print(state.message);
                            }
                            return Text(context.tr('core.error'));
                          case ArticleSuccess _:
                            return SizedBox(
                              height: 300,
                              width: 300,
                              child: PrettyQrView.data(
                                data: jsonEncode(
                                  state.articles
                                      .map((a) => a.toMap())
                                      .toList(),
                                ),
                                decoration: const PrettyQrDecoration(
                                  shape: PrettyQrSmoothSymbol(color: Colors.black, roundFactor: .0),
                                  quietZone: PrettyQrQuietZone.pixels(20),
                                  background:
                                      Colors.white,
                                ),
                              ),
                            );
                          default:
                            return CircularProgressIndicator();
                        }
                      },
                    ),
                    Text(
                      context.tr('modal.export'),
                      style: TextTheme.of(context).bodySmall!.apply(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;
      case 'import':
        String res = await handleScaning(context);
        if (res.isNotEmpty && context.mounted) {
          context.read<ArticleBloc>().add(
            ArticleImportEvent(
              json: res,
            ),
          );
        }
        break;
      case 'delete':
        handleDelete(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: BackButton(),
        ),
        title: Text(context.tr('core.card.article.title')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              onSelected: (String value) {
                handleClick(context, value);
              },
              itemBuilder: (BuildContext context) {
                return [
                  {'label': 'export', 'icon': Icons.qr_code_2_rounded},
                  {'label': 'import', 'icon': Icons.qr_code_scanner_rounded},
                  {'label': 'delete', 'icon': Icons.delete},
                ].map((Map<String, dynamic> choice) {
                  return PopupMenuItem<String>(
                    value: choice['label'],
                    child: Row(
                      spacing: 5,
                      children: [
                        Icon(choice['icon']),
                        Text(context.tr("article.options.${choice['label']}")),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (BuildContext context, ArticleState state) {
          switch (state) {
            case ArticleSuccess _:
              return state.articles.isEmpty
                  ? Center(child: (Text(context.tr('article.empty'))))
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
                              index: index,
                            );
                          },
                        ),
                      ],
                    ),
                  );
            case ArticleFailure _:
              return Text(context.tr('core.error'));
            default:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), SizedBox(height: 50)],
                ),
              );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          onPressed: () {
            handleAdd(context);
          },
          label: Text(context.tr('article.add')),
          icon: Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
