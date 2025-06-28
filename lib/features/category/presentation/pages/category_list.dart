import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';
import 'package:shopping_list/features/category/presentation/widgets/category_card.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {

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
                      pickerAreaBorderRadius: BorderRadius.all(Radius.circular(5)),
                      pickerAreaHeightPercent: .5,
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
      if (response == null) {
        throw FormatException();
      } else if (response != '') {
        Map<String, dynamic> data = json.decode(response) as Map<String, dynamic>;
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
                    BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (BuildContext context, CategoryState state) {
                        switch (state) {
                          case CategoryFailure _:
                            if (kDebugMode) {
                              print(state.message);
                            }
                            return Text(context.tr('core.error'));
                          case CategorySuccess _:
                            return SizedBox(
                              height: 300,
                              width: 300,
                              child: PrettyQrView.data(
                                data: jsonEncode(
                                  state.categories.map((a) => a.toMap()).toList(),
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
          context.read<CategoryBloc>().add(CategoryImportEvent(json: res));
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
        title: Text(context.tr('core.card.category.title')),
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
                        Text(context.tr("category.options.${choice['label']}")),
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
        buildWhen: (previous, state) {
          return state is CategorySuccess;
        },
        builder: (BuildContext context, CategoryState state) {
          final List<CategoryModel> categories =
              context.read<CategoryBloc>().getAllCategory();
          if (categories.isEmpty) {
            return Center(child: (Text(context.tr('category.empty'))));
          }
          return Padding(
            padding: const EdgeInsets.all(5),
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 60),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryCard(category: categories[index], index: index);
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
