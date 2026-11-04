import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shopping_list/features/cards/barcode_view.dart';
import 'package:shopping_list/features/cards/card_actions.dart';
import 'package:shopping_list/features/cards/card_face.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// A loyalty card full screen, ready for the checkout: its colour, the
/// barcode on white and the number in large print. The screen is at full
/// brightness while it is shown, so the till scanner reads it.
class CardPage extends StatefulWidget {
  final String cardId;

  const CardPage({super.key, required this.cardId});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  @override
  void initState() {
    super.initState();
    ScreenBrightness.instance.setApplicationScreenBrightness(1).ignore();
  }

  @override
  void dispose() {
    ScreenBrightness.instance.resetApplicationScreenBrightness().ignore();
    super.dispose();
  }

  void _leave() => context.canPop() ? context.pop() : context.go('/cards');

  @override
  Widget build(BuildContext context) {
    final card = context.watch<CardsCubit>().byId(widget.cardId);
    if (card == null) {
      // Deleted (or unknown): back to the cards.
      WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _leave() : null);
      return const Scaffold();
    }
    final ink = CardFace.onColor(card.color);
    final linked = context
        .watch<ListsCubit>()
        .state
        .where((l) => l.cardId == card.id)
        .map((l) => l.label)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ink == Colors.white ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: card.color,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: _leave,
                    icon: Icon(Icons.arrow_back_rounded, color: ink),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: context.l10n.commonEdit,
                    onPressed: () => editCard(context, card),
                    icon: Icon(Icons.edit_outlined, color: ink),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                card.label,
                style: TextStyle(color: ink, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
              ),
              Text(card.format.label, style: TextStyle(color: ink.withValues(alpha: 0.75), fontSize: 14)),
              const SizedBox(height: 28),
              // The barcode on white with its number, as the till expects it.
              DecoratedBox(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                  child: Column(
                    children: [
                      BarcodeView(card.code, format: card.format),
                      SelectableText(
                        card.code,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(Icons.light_mode_rounded, size: 18, color: ink.withValues(alpha: 0.8)),
                  Flexible(
                    child: Text(
                      context.l10n.cardsBrightnessHint,
                      style: TextStyle(color: ink.withValues(alpha: 0.8)),
                    ),
                  ),
                ],
              ),
              if (linked.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  context.l10n.cardsLinkedLists,
                  style: TextStyle(color: ink, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final label in linked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ink.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(color: ink, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
