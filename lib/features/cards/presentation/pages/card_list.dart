import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_state.dart';
import 'package:shopping_list/features/cards/presentation/widgets/custom_card.dart';

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  Future<String> handleScaning(BuildContext context, ScanMode mode) async {
    String barcodeScanRes = '';
    try {
      String res = await FlutterBarcodeScanner.scanBarcode(
        "#ffffff",
        context.tr('card.cancel'),
        false,
        mode,
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
                    BlocBuilder<CardBloc, CardState>(
                      builder: (BuildContext context, CardState state) {
                        switch (state) {
                          case CardFailure _:
                            if (kDebugMode) {
                              print(state.message);
                            }
                            return Text(context.tr('core.error'));
                          case CardSuccess _:
                            return SizedBox(
                              height: 300,
                              width: 300,
                              child: PrettyQrView.data(
                                data: jsonEncode(
                                  state.cards.map((a) => a.toMap()).toList(),
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
        String res = await handleScaning(context, ScanMode.QR);
        if (res.isNotEmpty && context.mounted) {
          context.read<CardBloc>().add(CardImportEvent(json: res));
        }
        break;
    }
  }

  String capitalize(String string) {
    return string.isNotEmpty
        ? "${string[0].toUpperCase()}${string.substring(1).toLowerCase()}"
        : string;
  }

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
        title: Text(context.tr('core.card.card.title')),
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
      body: BlocBuilder<CardBloc, CardState>(
        buildWhen: (previous, state) {
          return state is CardSuccess;
        },
        builder: (BuildContext context, CardState state) {
          final List<CardModel> cards = context.read<CardBloc>().getAllCard();
          if (cards.isEmpty) {
            return Center(child: (Text(context.tr('card.empty'))));
          }
          return Padding(
            padding: const EdgeInsets.all(5),
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListView.builder(
                    padding: EdgeInsets.only(bottom: 60),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return CustomCard(card: cards[index]);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          onPressed: () async {
            final labelController = TextEditingController();
            final codeController = TextEditingController();

            Color pickerColor = Theme.of(context).colorScheme.primary;

            void changeColor(Color color) {
              setState(() => pickerColor = color);
            }

            String? response = await showDialog<String>(
              context: context,
              builder:
                  (BuildContext context) => AlertDialog(
                    title: Text(context.tr('card.alert.add.title')),
                    content: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            TextField(
                              controller: labelController,
                              decoration: InputDecoration(
                                hintText: context.tr(
                                  'card.alert.add.placeholder.name',
                                ),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.name,
                            ),
                            TextField(
                              controller: codeController,
                              decoration: InputDecoration(
                                hintText: context.tr(
                                  'card.alert.add.placeholder.code',
                                ),
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    String res = await handleScaning(
                                      context,
                                      ScanMode.BARCODE,
                                    );
                                    if (res.isNotEmpty) {
                                      codeController.text = res;
                                    }
                                  },
                                  icon: Icon(Icons.camera_alt_rounded),
                                ),
                              ),
                              keyboardType: TextInputType.streetAddress,
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
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, ''),
                        child: Text(context.tr('card.alert.add.action.cancel')),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pop(
                              context,
                              labelController.text.isNotEmpty &&
                                      codeController.text.isNotEmpty
                                  ? '{"label": "${capitalize(labelController.text)}", "code": "${codeController.text}", "color": ${pickerColor.toARGB32()}}'
                                  : "",
                            ),
                        child: Text(context.tr('card.alert.add.action.add')),
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
                context.read<CardBloc>().add(
                  AddCardEvent(card: CardModel.fromMap(data)),
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
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainer,
                    duration: Durations.extralong4,
                  ),
                );
              }
            }
          },
          label: Text(context.tr('card.add')),
          icon: Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
