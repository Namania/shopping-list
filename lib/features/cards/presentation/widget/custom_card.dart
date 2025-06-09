import 'package:barcode_widget/barcode_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';

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
