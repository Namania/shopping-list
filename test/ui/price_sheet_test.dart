import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/features/prices/price_input_sheet.dart';
import 'package:shopping_list/l10n/app_localizations.dart';

/// Opens the price sheet from a button that can disappear while the sheet
/// is open, as an article does when checking it moves it into the cart.
class _Opener extends StatefulWidget {
  final ValueChanged<PriceInput?> onResult;
  final int? initialCents;

  const _Opener({required this.onResult, this.initialCents});

  @override
  State<_Opener> createState() => _OpenerState();
}

class _OpenerState extends State<_Opener> {
  bool _shown = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _shown
        ? Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final result = showPriceSheet(context, title: 'Tomates', initialCents: widget.initialCents);
                setState(() => _shown = false);
                widget.onResult(await result);
              },
              child: const Text('open'),
            ),
          )
        : const SizedBox(),
  );
}

void main() {
  Future<List<PriceInput?>> open(WidgetTester tester, {int? initialCents}) async {
    final results = <PriceInput?>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: _Opener(onResult: results.add, initialCents: initialCents),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('OK du clavier : la fenêtre se ferme et applique le prix', (tester) async {
    final results = await open(tester);
    await tester.enterText(find.byType(TextField), '12,5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect((results.single as SetPrice).cents, 1250);
  });

  testWidgets('Valider applique le prix', (tester) async {
    final results = await open(tester);
    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    expect((results.single as SetPrice).cents, 300);
  });

  testWidgets('Annuler n\'applique rien', (tester) async {
    final results = await open(tester);
    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(results.single, isNull);
  });

  testWidgets('modifier propose de supprimer', (tester) async {
    final results = await open(tester, initialCents: 250);
    expect(find.text('2.50'), findsOneWidget);
    await tester.tap(find.text('Supprimer le montant'));
    await tester.pumpAndSettle();
    expect(results.single, isA<DeletePrice>());
  });
}
