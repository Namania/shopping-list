import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/features/sharing/import_bundle.dart';
import 'package:shopping_list/features/sharing/import_preview_sheet.dart';
import 'package:shopping_list/l10n/app_localizations.dart';

void main() {
  final backup = ImportBundle(
    lists: [
      {'label': 'Courses de la semaine pour toute la famille', 'articles': []},
      {'label': 'Apéro', 'articles': []},
    ],
    cards: [
      {'label': 'Intermarché Super', 'code': '1', 'color': 0xFF1E5BC6},
    ],
    isBackup: true,
    createdAt: DateTime(2026, 11, 4, 18, 42),
  );

  Future<List<ImportChoice?>> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final results = <ImportChoice?>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(await showImportPreview(context, backup)),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('tout est coché, on décoche ce qu\'on ne veut pas', (tester) async {
    final results = await open(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Ajouter 3 éléments'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Apéro'), 100, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Apéro'));
    await tester.pump();
    await tester.tap(find.text('Ajouter 2 éléments'));
    await tester.pumpAndSettle();

    final selection = (results.single as AddSelected).selection;
    expect(selection.lists.single['label'], 'Courses de la semaine pour toute la famille');
    expect(selection.cards, hasLength(1));
  });

  testWidgets('une sauvegarde peut tout remplacer, après confirmation', (tester) async {
    final results = await open(tester);
    await tester.ensureVisible(find.text('Tout remplacer par cette sauvegarde'));
    await tester.tap(find.text('Tout remplacer par cette sauvegarde'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Remplacer mes données'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remplacer mes données'));
    await tester.pumpAndSettle();
    expect(results.single, isA<ReplaceAll>());
  });
}
