import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/core/theme/app_theme.dart';
import 'package:shopping_list/core/theme/palette.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/categories_page.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/test_database.dart';

void main() {
  late Database db;
  late CategoriesCubit categories;
  late ListsCubit lists;

  setUp(() async {
    db = await openTestDatabase();
    final changes = DataChanges();
    final repo = CategoryRepository(db);
    for (final label in ['Fruits', 'Frais', 'Épicerie']) {
      await repo.add(label: label, color: const Color(0xFF43A047));
    }
    categories = CategoriesCubit(repo, changes);
    lists = ListsCubit(ListRepository(db), changes);
    await categories.refresh();
    await lists.refresh();
  });

  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: categories),
          BlocProvider.value(value: lists),
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: buildTheme(Ambiance.warm, Brightness.light),
          home: const CategoriesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Database writes happen outside the fake clock.
  Future<void> settleDatabase(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('no swipe, no pencil, no "reorder" mode', (tester) async {
    await pump(tester);
    expect(find.byType(Dismissible), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Réorganiser'), findsNothing);
  });

  testWidgets('a long press then a drag moves a category', (tester) async {
    await pump(tester);
    final from = tester.getCenter(find.text('Fruits'));
    final to = tester.getCenter(find.text('Épicerie'));
    final gesture = await tester.startGesture(from);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveTo(Offset(from.dx, to.dy + 200), timeStamp: const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    await settleDatabase(tester);

    expect(categories.state.map((c) => c.label), ['Frais', 'Épicerie', 'Fruits']);
  });

  testWidgets('tap opens the sheet, which deletes after confirmation', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Frais'));
    await tester.pumpAndSettle();
    expect(find.text('Modifier la catégorie'), findsOneWidget);

    await tester.tap(find.text('Supprimer la catégorie'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();
    await settleDatabase(tester);

    expect(categories.state.map((c) => c.label), ['Fruits', 'Épicerie']);
    expect(find.text('Annuler'), findsOneWidget, reason: 'undo offered');
  });
}
