import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';

class CustomCard extends StatelessWidget {
  final CardModel card;

  const CustomCard({super.key, required this.card});

  void updateCard(BuildContext context, CardModel card) async {
    final labelController = TextEditingController();
    final codeController = TextEditingController();
    
    Color pickerColor = card.color.withAlpha(255);

    void changeColor(Color color) {
      pickerColor = color;
    }

    labelController.text = card.label;
    codeController.text = card.code;

    String? response = await showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(context.tr('card.alert.edit.title')),
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
                        hintText: context.tr('card.alert.edit.placeholder.name'),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.name,
                    ),
                    TextField(
                      controller: codeController,
                      decoration: InputDecoration(
                        hintText: context.tr('card.alert.edit.placeholder.code'),
                        border: OutlineInputBorder(),
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
                child: Text(context.tr('card.alert.edit.action.cancel')),
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
                child: Text(context.tr('card.alert.edit.action.update')),
              ),
            ],
          ),
    );

    try {
      if (response == null || response == '') {
        throw FormatException('No data');
      }
      Map<String, dynamic> data = json.decode(response) as Map<String, dynamic>;
      if (context.mounted) {
        context.read<CardBloc>().add(
          UpdateCardEvent(
            card: card,
            label: data["label"],
            code: data["code"].toString(),
            color: Color(data["color"]),
          ),
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

  String capitalize(String string) {
    return string.isNotEmpty
        ? "${string[0].toUpperCase()}${string.substring(1).toLowerCase()}"
        : string;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: GlobalKey(),
        onDismissed:
            (direction) => {
              context.read<CardBloc>().add(RemoveCardEvent(card: card)),
            },
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder:
                (BuildContext context) => AlertDialog(
                  title: Text(context.tr('card.alert.confirm.title')),
                  content: Text(context.tr('card.alert.confirm.description')),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(context.tr('card.alert.confirm.action.no')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(context.tr('card.alert.confirm.action.yes')),
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
                  "Supprimer",
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
                  "Supprimer",
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
            updateCard(context, card);
          },
          child: ExpansionTile(
            leading: Badge(
              padding: EdgeInsets.zero,
              label: CircleAvatar(
                backgroundColor: card.color,
              ),
            ),
            tilePadding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 15,
              right: 25,
            ),
            title: Text(
              card.label,
              style: TextTheme.of(context).bodyLarge!.apply(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            collapsedShape: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none,
            ),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none,
            ),
            trailing: Text(
              card.code,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(30),
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: card.code,
                  drawText: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
