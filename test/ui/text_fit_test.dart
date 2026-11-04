import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/core/theme/app_theme.dart';
import 'package:shopping_list/core/theme/palette.dart';
import 'package:shopping_list/features/cards/card_format.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/cards/cards_page.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/categories_page.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/lists/lists_page.dart';
import 'package:shopping_list/features/prices/calculator_page.dart';
import 'package:shopping_list/features/prices/price_repository.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/settings/settings_page.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';
import 'package:shopping_list/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/test_database.dart';

/// Phone widths in logical pixels: small, the dev phone, a large one.
const widths = [320.0, 360.0, 412.0];

/// System font sizes: default, large, largest accessibility size.
const textScales = [1.0, 1.3, 2.0];

late Database db;
late SettingsCubit settings;
late ListsCubit lists;
late CategoriesCubit categories;
late CardsCubit cards;
late PricesCubit prices;

/// Every text on screen that was cut short ("…" or clipped lines).
List<String> truncatedTexts(WidgetTester tester) => [
  for (final element in find.byType(RichText).evaluate())
    if ((element.renderObject as RenderParagraph?)?.didExceedMaxLines ?? false)
      (element.widget as RichText).text.toPlainText(),
];

/// The text scale the page is drawn at; changing it redraws the page.
final textScale = ValueNotifier(1.0);

/// The app's language on screen.
final language = ValueNotifier(const Locale('fr'));

/// The page on screen; changing it swaps pages without remounting the app.
final currentPage = ValueNotifier<Widget>(const SizedBox());

/// Mounts [page] once, translated in French; sizes and font scales are then
/// changed with [setScreen].
Future<void> pumpPage(WidgetTester tester, Widget page) async {
  currentPage.value = page;
  addTearDown(tester.view.reset);
  await setScreen(tester, width: widths.first, scale: textScales.first, settle: false);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: settings),
        BlocProvider.value(value: lists),
        BlocProvider.value(value: categories),
        BlocProvider.value(value: cards),
        BlocProvider.value(value: prices),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: buildTheme(Ambiance.warm, Brightness.light),
          home: ValueListenableBuilder(
            valueListenable: textScale,
            builder: (context, scale, _) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
              child: ValueListenableBuilder(valueListenable: currentPage, builder: (_, page, _) => page),
            ),
          ),
        ),
      ),
    ),
  );
  // Translations load from the asset bundle, outside the fake clock: wait
  // until the page shows its text.
  for (var i = 0; i < 40 && find.byType(RichText).evaluate().isEmpty; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
  expect(find.byType(RichText), findsWidgets, reason: 'page never rendered');
}

Future<void> setScreen(
  WidgetTester tester, {
  required double width,
  required double scale,
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = Size(width * 2, 800 * 2);
  textScale.value = scale;
  if (settle) await tester.pumpAndSettle();
}

/// Checks [page] at every width and font scale.
Future<void> checkAllScreens(WidgetTester tester, Widget page, String name) async {
  currentPage.value = page;
  await tester.pumpAndSettle();
  for (final width in widths) {
    for (final scale in textScales) {
      await setScreen(tester, width: width, scale: scale);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 5000));
      await tester.pumpAndSettle();
      await expectEverythingFits(tester, '$name ${width.toInt()} dp, police ×$scale');
    }
  }
}

/// Scrolls the page from top to bottom, checking every screenful.
Future<void> expectEverythingFits(WidgetTester tester, String where) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 12; i++) {
    expect(tester.takeException(), isNull, reason: '$where: layout error');
    final cut = truncatedTexts(tester);
    expect(cut, isEmpty, reason: '$where: text cut short: ${cut.join(" | ")}');
    final before = tester.getTopLeft(find.byType(RichText).first);
    await tester.drag(scrollable, const Offset(0, -500));
    await tester.pumpAndSettle();
    if (tester.getTopLeft(find.byType(RichText).first) == before) break;
  }
}

/// Tests draw text with a placeholder font whose glyphs are squares as wide
/// as they are tall, far wider than real text. Load the fonts a phone uses
/// so widths are real: Roboto (Android's system font, shipped with Flutter),
/// the Material icons, and the app's own fonts.
Future<void> loadRealFonts() async {
  final materialFonts = '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  Future<ByteData> file(String path) async => ByteData.sublistView(await File(path).readAsBytes());
  final roboto = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(file('$materialFonts/Roboto-$weight.ttf'));
  }
  await roboto.load();
  await (FontLoader('MaterialIcons')..addFont(file('$materialFonts/MaterialIcons-Regular.otf'))).load();
  for (final (family, file, weights) in [
    ('Bricolage Grotesque', 'BricolageGrotesque', ['Medium', 'SemiBold', 'Bold', 'ExtraBold']),
    ('Figtree', 'Figtree', ['Regular', 'Medium', 'SemiBold', 'Bold']),
  ]) {
    final loader = FontLoader(family);
    for (final weight in weights) {
      loader.addFont(rootBundle.load('assets/fonts/$file-$weight.ttf'));
    }
    await loader.load();
  }
  await (FontLoader('Cookie')..addFont(rootBundle.load('assets/fonts/Cookie-Regular.ttf'))).load();
}

void main() {
  setUpAll(() async {
    await loadRealFonts();
    PackageInfo.setMockInitialValues(
      appName: 'Shopping List',
      packageName: 'fr.namania.shopping_list',
      version: '1.3.7',
      buildNumber: '13',
      buildSignature: '',
    );

    db = await openTestDatabase();
    final changes = DataChanges();
    final categoryRepo = CategoryRepository(db);
    final fruits = await categoryRepo.add(label: 'Fruits & légumes', color: const Color(0xFF43A047));
    final card = await CardRepository(db).add(
      label: 'Intermarché Super',
      code: '2501234567890',
      color: const Color(0xFF1E5BC6),
      format: CardFormat.ean13,
    );
    final listRepo = ListRepository(db);
    await listRepo.add('Courses de la semaine pour toute la famille');
    await listRepo.add('Apéro');
    final first = (await listRepo.all()).first;
    await listRepo.update(first.copyWith(cardId: card.id));
    await listRepo.addArticle(listId: first.id, label: 'Tomates cerises', category: fruits);
    final tomatoes = (await listRepo.all()).first.articles.first;
    final priceRepo = PriceRepository(db);
    await priceRepo.setForArticle(listId: first.id, articleId: tomatoes.id, cents: 349);
    await priceRepo.addManual(cents: 123456, listId: first.id);

    settings = SettingsCubit(SettingsRepository(db), const AppSettings(calculatorEnabled: true));
    lists = ListsCubit(listRepo, changes);
    categories = CategoriesCubit(categoryRepo, changes);
    cards = CardsCubit(CardRepository(db), changes);
    prices = PricesCubit(PriceRepository(db), changes);
    await Future.wait([lists.refresh(), categories.refresh(), cards.refresh(), prices.refresh()]);
  });

  tearDownAll(() => db.close());

  testWidgets(
    'Réglages, Mes listes, Catégories, Cartes et Montants : rien ne dépasse, quel que soit l\'écran',
    (tester) async {
      await pumpPage(tester, const SettingsPage());
      for (final locale in AppLocalizations.supportedLocales) {
        language.value = locale;
        await tester.pumpAndSettle();
        await checkAllScreens(tester, const SettingsPage(), 'Réglages (${locale.languageCode})');
        await checkAllScreens(tester, const ListsPage(), 'Mes listes (${locale.languageCode})');
        await checkAllScreens(tester, const CategoriesPage(), 'Catégories (${locale.languageCode})');
        await checkAllScreens(tester, const CardsPage(), 'Cartes (${locale.languageCode})');
        await checkAllScreens(tester, const CalculatorPage(), 'Montants (${locale.languageCode})');
      }
    },
  );
}
