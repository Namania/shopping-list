import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_state.dart';
import 'package:shopping_list/features/cards/presentation/widgets/custom_card.dart';

class CardList extends StatelessWidget {
  const CardList({super.key});

  Future<String> handleScaning(BuildContext context) async {
    String barcodeScanRes = '';
    try {
      String res = await FlutterBarcodeScanner.scanBarcode(
        "#ffffff",
        context.tr('card.cancel'),
        false,
        ScanMode.BARCODE,
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
      ),
      body: BlocBuilder<CardBloc, CardState>(
        builder: (BuildContext context, CardState state) {
          switch (state) {
            case CardLoading _:
              return CircularProgressIndicator();
            case CardSuccess _:
              return state.cards.isEmpty
                  ? Center(child: (Text(context.tr('card.empty'))))
                  : SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListView.builder(
                          padding: EdgeInsets.only(bottom: 60),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.cards.length,
                          itemBuilder: (context, index) {
                            return CustomCard(card: state.cards[index]);
                          },
                        ),
                      ],
                    ),
                  );
            case CardFailure _:
              return Text(context.tr('core.error'));
            default:
              return CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          onPressed: () async {
            final labelController = TextEditingController();
                final codeController = TextEditingController();

                String? response = await showDialog<String>(
                  context: context,
                  builder:
                      (BuildContext context) => AlertDialog(
                        title: Text(context.tr('card.alert.add.title')),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              TextField(
                                controller: labelController,
                                decoration: InputDecoration(
                                  hintText: context.tr('card.alert.add.placeholder.name'),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.name,
                              ),
                              TextField(
                                controller: codeController,
                                decoration: InputDecoration(
                                  hintText: context.tr('card.alert.add.placeholder.code'),
                                  border: OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    onPressed: () async {
                                      String res = await handleScaning(context);
                                      if (res.isNotEmpty) {
                                        codeController.text = res;
                                      }
                                    },
                                    icon: Icon(Icons.camera_alt_rounded),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
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
                                  labelController.text != "" &&
                                          codeController.text != ""
                                      ? '{"label": "${labelController.text}", "code": "${codeController.text}"}'
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
