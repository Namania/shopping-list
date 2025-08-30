import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';
import 'package:shopping_list/features/category/presentation/widgets/category_card.dart';

import '../../../../core/shared/utils.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  bool movableMode = false;
  bool _isDragging = false;
  List<CategoryModel> categories = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void handleDelete(BuildContext context) async {
    bool? res = await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Text(context.tr('category.alert.confirm.title')),
            content: Text(context.tr('category.alert.confirm.description.all')),
            actions: <Widget>[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(context.tr('category.alert.confirm.action.no')),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(context.tr('category.alert.confirm.action.yes')),
                ),
              ),
            ],
          ),
    );
    if (res != null && context.mounted) {
      context.read<CategoryBloc>().add(ClearCategoryEvent());
    }
  }

  void handleAdd(BuildContext context) async {
    final labelController = TextEditingController();

    Color pickerColor = Theme.of(context).colorScheme.primary;

    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

    String? response = await showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(context.tr('category.alert.add.title')),
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
                        'category.alert.add.placeholder.name',
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ColorPicker(
                      hexInputBar: false,
                      pickerColor: pickerColor,
                      onColorChanged: changeColor,
                      displayThumbColor: false,
                      labelTypes: [],
                      enableAlpha: false,
                      pickerAreaBorderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      pickerAreaHeightPercent: .5,
                      paletteType: PaletteType.hsl,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: Text(context.tr('category.alert.add.action.cancel')),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      labelController.text != ""
                          ? '{"label": "${labelController.text[0].toUpperCase() + labelController.text.substring(1)}", "color": ${pickerColor.toARGB32()}}'
                          : "",
                    ),
                child: Text(context.tr('category.alert.add.action.add')),
              ),
            ],
          ),
    );

    try {
      if (response != null && response != '') {
        Map<String, dynamic> data =
            json.decode(response) as Map<String, dynamic>;
        if (context.mounted) {
          context.read<CategoryBloc>().add(
            AddCategoryEvent(category: CategoryModel.fromMap(data)),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (BuildContext context, CategoryState state) {
                      switch (state) {
                        case CategoryFailure _:
                          if (kDebugMode) print(state.message);
                          return Text(
                            context.tr('core.error'),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        case CategorySuccess _:
                          final rawJson = {
                            "action": "importCategories",
                            "json":
                                state.categories.map((a) => a.toMap()).toList(),
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
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      switch (state) {
                        case CategorySuccess _:
                          return TextButton.icon(
                            onPressed: () async {
                              if (state.categories.isNotEmpty) {
                                String data = jsonEncode(
                                  state.categories
                                      .map((a) => a.toMap())
                                      .toList(),
                                );
                                Directory temp = await getTemporaryDirectory();
                                String path = "${temp.path}/categories.json";
                                File(path).writeAsStringSync(data);

                                if (context.mounted) {
                                  await SharePlus.instance.share(
                                    ShareParams(
                                      files: [XFile(path)],
                                      text: context.tr(
                                        'core.settings.shareCategoryMessage',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.tr('category.empty'),
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
                    style: TextTheme.of(context).bodySmall!.apply(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                              context.read<CategoryBloc>().add(
                                CategoryImportEvent(
                                  json: jsonEncode(decoded['json']),
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
                              context.read<CategoryBloc>().add(
                                CategoryImportEvent(
                                  json:
                                      await result.files.first.xFile
                                          .readAsString(),
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
      case 'move':
        setState(() {
          movableMode = true;
        });
        break;
    }
  }

  void removeCategory(CategoryModel category) {
    setState(() {
      categories.remove(category);
    });
  }

  void _startScroll(double offset) {
    _scrollTimer ??= Timer.periodic(Duration(milliseconds: 50), (_) {
      if (_scrollController.hasClients) {
        final newOffset = _scrollController.offset + offset;
        _scrollController.animateTo(
          newOffset.clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          ),
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _stopScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

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
        title: Text(context.tr('core.card.category.title')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child:
                movableMode
                    ? IconButton(
                      onPressed: () {
                        setState(() {
                          movableMode = false;
                        });
                      },
                      icon: Icon(Icons.check_rounded),
                    )
                    : PopupMenuButton<String>(
                      onSelected: (value) => handleClick(context, value),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      icon: const Icon(Icons.more_vert),
                      tooltip: context.tr("category.options.tooltip"),
                      itemBuilder: (context) {
                        final choices = [
                          {'label': 'share', 'icon': Icons.share_rounded},
                          {'label': 'import', 'icon': Icons.download_rounded},
                          {'label': 'move', 'icon': Icons.shuffle_rounded},
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
                                  context.tr(
                                    "category.options.${choice['label']}",
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (BuildContext context, CategoryState state) {
          if (state is CategorySuccess) {
            categories = state.categories;
          }
          if (categories.isEmpty) {
            return Center(child: (Text(context.tr('category.empty'))));
          }
          return Padding(
            padding: const EdgeInsets.all(5),
            child:
                movableMode
                    ? Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerMove: (event) {
                        if (_isDragging) {
                          final y = event.position.dy;
                          final screenHeight =
                              MediaQuery.of(context).size.height;

                          if (y < 100) {
                            _startScroll(-10);
                          } else if (y > screenHeight - 100) {
                            _startScroll(10);
                          } else {
                            _stopScroll();
                          }
                        }
                      },
                      onPointerUp: (_) {
                        _stopScroll();
                        _isDragging = false;
                      },
                      child: ReorderableListView.builder(
                        scrollController: _scrollController,
                        proxyDecorator: (
                          Widget child,
                          int index,
                          Animation<double> animation,
                        ) {
                          _isDragging = true;
                          return Material(
                            elevation: 10,
                            color: Colors.transparent,
                            child: child,
                          );
                        },
                        onReorder: (int oldIndex, int newIndex) {
                          _isDragging = false;
                          _stopScroll();
                          if (newIndex > oldIndex) newIndex -= 1;
                          context.read<CategoryBloc>().add(
                            RerangeCategoryEvent(
                              oldIndex: oldIndex,
                              newIndex: newIndex,
                            ),
                          );
                          setState(() {
                            final item = categories.removeAt(oldIndex);
                            categories.insert(newIndex, item);
                          });
                        },
                        padding: EdgeInsets.only(bottom: 60),
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return CategoryCard(
                            key: ValueKey(
                              "${categories[index].label}${categories[index].color.toHexString()}",
                            ),
                            index: index,
                            category: categories[index],
                            movableMode: movableMode,
                            removeCategory: removeCategory,
                          );
                        },
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.only(bottom: 60),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCard(
                          category: categories[index],
                          index: index,
                          movableMode: movableMode,
                          removeCategory: removeCategory,
                        );
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
          label: Text(context.tr('category.add')),
          icon: Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
