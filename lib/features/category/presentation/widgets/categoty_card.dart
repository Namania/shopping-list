import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int index;

  const CategoryCard({super.key, required this.category, required this.index});

  void deleteCategory(BuildContext context) {
    context.read<CategoryBloc>().add(RemoveCategoryEvent(index: index));
  }

  void editCategory(BuildContext context, CategoryModel category) async {
    final labelController = TextEditingController();

    Color pickerColor = category.color;

    void changeColor(Color color) {
      pickerColor = color;
    }

    labelController.text = category.label;

    String? response = await showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(context.tr('category.alert.edit.title')),
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
                        'category.alert.edit.placeholder.name',
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
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: Text(context.tr('category.alert.edit.action.cancel')),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      labelController.text != ""
                          ? '{"label": "${labelController.text}", "color": ${pickerColor.toARGB32()}}'
                          : "",
                    ),
                child: Text(context.tr('category.alert.edit.action.update')),
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
          context.read<CategoryBloc>().add(
            UpdateCategoryEvent(
              category: category,
              label: data["label"],
              color: Color(data["color"]),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: GlobalKey(),
        onDismissed:
            (direction) => {
              {deleteCategory(context)},
            },
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder:
                (BuildContext context) => AlertDialog(
                  title: Text(context.tr('category.alert.confirm.title')),
                  content: Text(
                    context.tr('category.alert.confirm.description.one'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        context.tr('category.alert.confirm.action.no'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        context.tr('category.alert.confirm.action.yes'),
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
                  context.tr('category.delete'),
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
                  context.tr('category.delete'),
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
        child: GestureDetector(
          onLongPress: () {
            editCategory(context, category);
          },
          child: ListTile(
            leading: Badge(
              padding: EdgeInsets.all(3),
              label: const SizedBox(height: 10),
              backgroundColor: category.color,
            ),
            title: Text(category.label, style: TextTheme.of(context).bodyLarge),
          ),
        ),
      ),
    );
  }
}
