import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/app.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/core/database/app_database.dart';
import 'package:shopping_list/core/database/backup_exclusion.dart';
import 'package:shopping_list/core/database/legacy_sources.dart';
import 'package:shopping_list/features/backup/restore_points.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/cards/cards_cubit.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/lists/lists_cubit.dart';
import 'package:shopping_list/features/prices/price_repository.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';
import 'package:shopping_list/features/sharing/data_importer.dart';

/// Opens the database, migrates older data, loads every cubit and returns
/// the widget tree to run. Every cubit is loaded before the first frame so
/// no page starts empty.
/// [initialLocation] opens another page than the one chosen in the settings.
Future<Widget> bootstrap({
  DatabaseFactory? databaseFactory,
  String? databasePath,
  String? initialLocation,
}) async {
  final db = await AppDatabase.open(factory: databaseFactory, path: databasePath);
  await migrateLegacyData(db);

  final changes = DataChanges();
  final lists = ListsCubit(ListRepository(db), changes);
  final categories = CategoriesCubit(CategoryRepository(db), changes);
  final cards = CardsCubit(CardRepository(db), changes);
  final prices = PricesCubit(PriceRepository(db), changes);
  await Future.wait([lists.refresh(), categories.refresh(), cards.refresh(), prices.refresh()]);
  final settings = await SettingsCubit.load(SettingsRepository(db));
  final restorePointsDirectory = await Directory(
    '${(await getApplicationSupportDirectory()).path}/restore_points',
  ).create(recursive: true);
  unawaited(excludeFromCloudBackup([File(db.path).parent.path, restorePointsDirectory.path]));
  final restorePoints = RestorePoints(db, changes, restorePointsDirectory);
  unawaited(restorePoints.takeDailyIfDue());

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: DataImporter(db, changes)),
      RepositoryProvider.value(value: restorePoints),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: settings),
        BlocProvider.value(value: lists),
        BlocProvider.value(value: categories),
        BlocProvider.value(value: cards),
        BlocProvider.value(value: prices),
      ],
      child: App(initialLocation: initialLocation),
    ),
  );
}
