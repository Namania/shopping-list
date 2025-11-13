import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/utils/delete_alert_dialog.dart';
import 'package:shopping_list/core/utils/handle_menu_button.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';
import 'package:shopping_list/features/category/presentation/widgets/category_card.dart';

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
    bool? res = await DeleteAlertDialog.dialog(context, 'category', description: true);
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

  void handleClick(BuildContext context, String value) async {
    HandleMenuButton.click(
      context: context,
      action: value,
      data: context.read<CategoryBloc>().getAllCategory(),
      deepLinkAction: "importCategories",
      import: (data) {
        context.read<CategoryBloc>().add(
          CategoryImportEvent(json: data),
        );
      },
      onDelete: () {
        handleDelete(context);
      },
      onMove: () {
        setState(() {
          movableMode = true;
        });
      }
    );
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
          return movableMode
              ? Listener(
                behavior: HitTestBehavior.translucent,
                onPointerMove: (event) {
                  if (_isDragging) {
                    final y = event.position.dy;
                    final screenHeight = MediaQuery.of(context).size.height;

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
                  padding: EdgeInsets.only(
                    top: 5,
                    left: 5,
                    right: 5,
                    bottom: 65,
                  ),
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
                padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 65),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    category: categories[index],
                    index: index,
                    movableMode: movableMode,
                    removeCategory: removeCategory,
                  );
                },
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
