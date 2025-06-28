import 'dart:collection';
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
import 'package:shopping_list/features/article/presentation/widgets/article_category.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({super.key});

  @override
  State<ArticleList> createState() => _ArticleListState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _ArticleListState extends State<ArticleList> {
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

    List<CategoryModel> categories =
        context.read<CategoryBloc>().getAllCategory();
    CategoryModel otherCategory = CategoryModel(
      label: context.tr('category.default'),
      color: Theme.of(context).colorScheme.primary,
    );
    categories.insert(0, otherCategory);
    List<MenuEntry> categoryEntries = UnmodifiableListView<MenuEntry>(
      categories.map<MenuEntry>(
        (CategoryModel c) => MenuEntry(
          value: c.label,
          labelWidget: Text(c.label),
          label: c.label,
        ),
      ),
    );
    String categoryEntriesValue = categories.first.label;

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
                  DropdownMenu<String>(
                    initialSelection: categoryEntriesValue,
                    onSelected: (String? value) {
                      categoryEntriesValue = value!;
                    },
                    dropdownMenuEntries: categoryEntries,
                    selectedTrailingIcon: Icon(Icons.arrow_drop_up_rounded),
                    trailingIcon: Icon(Icons.arrow_drop_down_rounded),
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
                          ? '{"label": "${labelController.text}", "category": ${categories.where((c) => c.label == categoryEntriesValue).first.toJson()}, "done": false}'
                          : "",
                    ),
                child: Text(context.tr('article.alert.add.action.add')),
              ),
            ],
          ),
    );

    try {
      if (response == null) {
        throw FormatException();
      } else if (response != '') {
        Map<String, dynamic> data =
            json.decode(response) as Map<String, dynamic>;
        if (context.mounted) {
          context.read<ArticleBloc>().add(
            AddArticleEvent(article: ArticleModel.fromMap(data)),
          );
        }
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
                                  state.articles.map((a) => a.toMap()).toList(),
                                ),
                                decoration: const PrettyQrDecoration(
                                  shape: PrettyQrSmoothSymbol(
                                    color: Colors.black,
                                    roundFactor: .0,
                                  ),
                                  quietZone: PrettyQrQuietZone.pixels(20),
                                  background: Colors.white,
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
              defaultCategory: CategoryModel(
                label: context.tr('category.default'),
                color: Theme.of(context).colorScheme.primary,
              ),
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
    context.read<CategoryBloc>().add(CategoryGetAllEvent());
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
        buildWhen: (previous, state) {
          return state is ArticleSuccess;
        },
        builder: (BuildContext context, ArticleState state) {
          final List<ArticleModel> articles =
              context.read<ArticleBloc>().getAllArticle();
          if (articles.isEmpty) {
            return Center(child: (Text(context.tr('article.empty'))));
          }
          return Padding(
            padding: const EdgeInsets.all(5),
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 60),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return index == 0 ||
                        articles[index - 1].category.label !=
                            articles[index].category.label
                    ? ArticleCategory(article: articles[index], index: index)
                    : ArticleCard(article: articles[index], index: index);
              },
            ),
          );
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
