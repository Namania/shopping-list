import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopping_list/core/shared/cubit/setting_default_category_position.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/article/presentation/widgets/article_card.dart';
import 'package:shopping_list/features/article/presentation/widgets/article_category.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';

import '../../../../core/shared/utils.dart';

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
      if (response != null && response != '') {
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
      case 'share':
        showModalBottomSheet<void>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Container(
                      width: 75,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  BlocBuilder<ArticleBloc, ArticleState>(
                    builder: (context, state) {
                      switch (state) {
                        case ArticleFailure _:
                          if (kDebugMode) print(state.message);
                          return Text(
                            context.tr('core.error'),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        case ArticleSuccess _:
                          final rawJson = {
                            "action": "importArticles",
                            "json":
                                state.articles.map((a) => a.toMap()).toList(),
                          };

                          final encodedData = Uri.encodeComponent(
                            Utils.compressJson(jsonEncode(rawJson)),
                          );
                          final deepLink =
                              'shopping-list://launch?data=$encodedData';

                          return SizedBox(
                            height: 250,
                            width: 250,
                            child: PrettyQrView.data(
                              data: deepLink,
                              decoration: const PrettyQrDecoration(
                                shape: PrettyQrSmoothSymbol(
                                  color: Colors.black,
                                  roundFactor: 0.0,
                                ),
                                quietZone: PrettyQrQuietZone.pixels(20),
                                background: Colors.white,
                              ),
                            ),
                          );
                        default:
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(),
                          );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<ArticleBloc, ArticleState>(
                    builder: (context, state) {
                      switch (state) {
                        case ArticleSuccess _:
                          return TextButton.icon(
                            onPressed: () async {
                              if (state.articles.isNotEmpty) {
                                String data = jsonEncode(
                                  state.articles.map((a) => a.toMap()).toList(),
                                );
                                Directory temp = await getTemporaryDirectory();
                                String path = "${temp.path}/articles.json";
                                File(path).writeAsStringSync(data);

                                if (context.mounted) {
                                  await SharePlus.instance.share(
                                    ShareParams(
                                      files: [XFile(path)],
                                      text: context.tr(
                                        'core.settings.shareArticleMessage',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.tr('article.empty'),
                                      style: TextTheme.of(context).labelLarge,
                                    ),
                                    backgroundColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainer,
                                    duration: Durations.extralong4,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.insert_drive_file_rounded),
                            label: Text(context.tr('modal.send_file')),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              textStyle: Theme.of(context).textTheme.labelLarge,
                            ),
                          );
                        default:
                          return CircularProgressIndicator();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('modal.export'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
        break;
      case 'import':
        showModalBottomSheet<void>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Container(
                      width: 75,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            String res = await handleScaning(context);
                            Uri? uri = Uri.tryParse(res);
                            if (res != "" && uri != null && context.mounted) {
                              final decoded = json.decode(
                                Utils.decompressJson(uri.queryParameters['data'] ?? ''),
                              );
                              context.read<ArticleBloc>().add(
                                ArticleImportEvent(
                                  json: jsonEncode(decoded['json']),
                                  defaultCategory: CategoryModel(
                                    label: context.tr('category.default'),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 36,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.tr('modal.scan'),
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                  type: FileType.custom,
                                  allowMultiple: false,
                                  allowedExtensions: ["json"],
                                );
                            if (context.mounted && result != null) {
                              context.read<ArticleBloc>().add(
                                ArticleImportEvent(
                                  json:
                                      await result.files.first.xFile
                                          .readAsString(),
                                  defaultCategory: CategoryModel(
                                    label:
                                        context.mounted
                                            ? context.tr('category.default')
                                            : "Other",
                                    color:
                                        context.mounted
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Colors.black,
                                  ),
                                ),
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.insert_drive_file_rounded,
                                  size: 36,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.tr('modal.pick_file'),
                                  style: Theme.of(context).textTheme.labelLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
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
              onSelected: (value) => handleClick(context, value),
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
                          context.tr("article.options.${choice['label']}"),
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
          final List<ArticleModel> data =
              context.read<ArticleBloc>().getAllArticle();
          final List<CategoryModel> categories =
              context.read<CategoryBloc>().getAllCategory();

          final List<ArticleModel> articles = [];
          categories.insert(
            context.read<SettingDefaultCategoryPosition>().getValue()
                ? 0
                : categories.length,
            CategoryModel(
              label: context.tr('category.default'),
              color: Theme.of(context).colorScheme.primary,
            ),
          );
          for (CategoryModel category in categories) {
            articles.addAll(data.where((a) => a.category == category));
          }
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
                    ? ArticleCategory(article: articles[index])
                    : ArticleCard(article: articles[index]);
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
