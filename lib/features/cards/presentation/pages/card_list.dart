import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_state.dart';

class CardList extends StatelessWidget {
  const CardList({super.key});

  Future<String> handleScaning(BuildContext context) async {
    String barcodeScanRes = '';
    try {
      String res = await FlutterBarcodeScanner.scanBarcode(
        "#ffffff",
        "Annuler",
        false,
        ScanMode.BARCODE,
      );
      if (res != "-1") {
        barcodeScanRes = res;
      }
    } catch (e) {
      print("Erreur lors du scan");
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
        title: const Text("Mes cartes"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () async {
                final labelController = TextEditingController();
                final codeController = TextEditingController();

                String? response = await showDialog<String>(
                  context: context,
                  builder:
                      (BuildContext context) => AlertDialog(
                        title: const Text('Ajouter une carte'),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              TextField(
                                controller: labelController,
                                decoration: InputDecoration(
                                  hintText: "Entrez le nom de la boutique",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.name,
                              ),
                              TextField(
                                controller: codeController,
                                decoration: InputDecoration(
                                  hintText: "Entrez le code de la carte",
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
                            child: const Text('Annuler'),
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
                            child: const Text('Ajouter'),
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
                          "Une erreur est survenue !",
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
              icon: Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CardBloc, CardState>(
        builder: (BuildContext context, CardState state) {
          switch (state) {
            case CardLoading _:
              return CircularProgressIndicator();
            case CardSuccess _:
              return state.cards.isEmpty
                  ? Center(child: (Text("Aucune carte enregistré !")))
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
              return Text("Une erreur est survenue !");
            default:
              return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final CardModel card;

  const CustomCard({super.key, required this.card});

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
                  title: const Text("Confirmez"),
                  content: const Text("Voulez-vous vraiment le supprimer ?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Non'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Oui'),
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
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  "Supprimer",
                  style: TextTheme.of(context).bodyLarge!.apply(
                    color: Theme.of(context).colorScheme.primary,
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        child: ExpansionTile(
          title: Text(
            card.label,
            style: TextTheme.of(
              context,
            ).bodyLarge!.apply(color: Theme.of(context).colorScheme.primary),
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
    );
  }
}
