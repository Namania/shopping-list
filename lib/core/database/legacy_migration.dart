import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/features/cards/card_repository.dart';
import 'package:shopping_list/features/categories/category_repository.dart';
import 'package:shopping_list/features/lists/list_repository.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/settings_repository.dart';
import 'package:uuid/uuid.dart';

/// Raw data of versions <= 1.3.x, as stored by `shared_preferences` (JSON
/// strings) and `hydrated_bloc` (one map per cubit).
class LegacyData {
  final String? lists;
  final String? cards;
  final String? categories;
  final String? prices;
  final String? manualPrices;
  final Map<String, dynamic>? theme;
  final Map<String, dynamic>? startRoute;
  final Map<String, dynamic>? categoryPosition;
  final Map<String, dynamic>? calculator;

  /// The language picked in the app (easy_localization), e.g. "fr".
  final String? language;

  const LegacyData({
    this.lists,
    this.cards,
    this.categories,
    this.prices,
    this.manualPrices,
    this.theme,
    this.startRoute,
    this.categoryPosition,
    this.calculator,
    this.language,
  });
}

/// What a [LegacyMigration] imported. [skipped] counts the entries (or whole
/// stores) that could not be read; the caller keeps the legacy stores as a
/// safety copy when it is not 0.
class LegacyMigrationReport {
  int categories = 0;
  int cards = 0;
  int lists = 0;
  int articles = 0;
  int prices = 0;
  int skipped = 0;

  bool get complete => skipped == 0;

  @override
  String toString() =>
      'categories: $categories, cards: $cards, lists: $lists, articles: $articles, prices: $prices, skipped: $skipped';
}

/// Copies the data of versions <= 1.3.x into the SQLite database, once.
///
/// Everything happens in one transaction: either the whole import is
/// written and the migration is marked done, or nothing is. An entry (or a
/// store) that cannot be read is skipped and counted, never fatal, so one
/// bad article doesn't cost the others.
class LegacyMigration {
  static const _doneKey = 'legacy_migrated';

  static Future<bool> isDone(Database db) async {
    final rows = await db.query(SettingsRepository.table, where: 'key = ?', whereArgs: [_doneKey]);
    return rows.isNotEmpty;
  }

  static Future<LegacyMigrationReport> run(Database db, LegacyData data, {Uuid uuid = const Uuid()}) {
    final report = LegacyMigrationReport();
    final categories = CategoryRepository(db, uuid: uuid);
    final cards = CardRepository(db, uuid: uuid);
    final lists = ListRepository(db, uuid: uuid);

    return db.transaction((txn) async {
      for (final map in _decodeStore(data.categories, report)) {
        await _attempt(report, () async {
          await categories.importOneIn(txn, map);
          report.categories++;
        });
      }
      for (final map in _decodeStore(data.cards, report)) {
        await _attempt(report, () async {
          if (await cards.importOneIn(txn, map, keepIds: true)) report.cards++;
        });
      }
      for (final map in _decodeLists(data.lists, uuid, report)) {
        await _attempt(report, () async {
          final listId = await lists.importListIn(txn, map, keepIds: true);
          report.lists++;
          final known = await CategoryRepository.allIn(txn);
          for (final article in ListRepository.articlesOf(map)) {
            await _attempt(report, () async {
              await lists.importArticleIn(txn, listId, article, known);
              report.articles++;
            });
          }
        });
      }
      await _importPrices(txn, data, uuid, report);

      await SettingsRepository.saveIn(txn, _settings(data));
      await txn.insert(SettingsRepository.table, {'key': _doneKey, 'value': '1'});
      return report;
    });
  }

  /// Runs [action]; a malformed entry (bad type, missing key, SQL error) is
  /// counted as skipped instead of aborting the migration.
  static Future<void> _attempt(LegacyMigrationReport report, Future<void> Function() action) async {
    try {
      await action();
    } on TypeError {
      report.skipped++;
    } on FormatException {
      report.skipped++;
    } on DatabaseException {
      report.skipped++;
    }
  }

  /// Each legacy store is a JSON array whose items are themselves
  /// JSON-encoded strings. A store that cannot be decoded counts as one
  /// skipped entry and yields nothing.
  static List<Map<String, dynamic>> _decodeStore(String? json, LegacyMigrationReport report) {
    if (json == null || json.isEmpty) return const [];
    try {
      return (jsonDecode(json) as List<dynamic>)
          .map((item) => (item is String ? jsonDecode(item) : item) as Map<String, dynamic>)
          .toList();
    } on FormatException {
      report.skipped++;
    } on TypeError {
      report.skipped++;
    }
    return const [];
  }

  /// Versions < 1.2 stored a flat list of articles instead of a list of lists.
  static List<Map<String, dynamic>> _decodeLists(String? json, Uuid uuid, LegacyMigrationReport report) {
    final items = _decodeStore(json, report);
    if (items.isEmpty || items.first.containsKey('articles')) return items;
    return [
      {'id': uuid.v4(), 'label': 'Default', 'card': '', 'articles': items},
    ];
  }

  static Future<void> _importPrices(
    DatabaseExecutor txn,
    LegacyData data,
    Uuid uuid,
    LegacyMigrationReport report,
  ) async {
    final listIds = (await txn.query('lists', columns: ['id'])).map((r) => r['id']).toSet();
    final listOfArticle = {
      for (final row in await txn.query('articles', columns: ['id', 'list_id'])) row['id']: row['list_id'],
    };
    final pricedArticles = <String>{};

    Future<void> insert(Map<String, dynamic> map, {required bool linked}) async {
      final String? listId;
      if (linked) {
        // The price of an article belongs to the article's list, whatever the
        // entry says. One price per article.
        final articleId = map['id_article'] as String;
        if (!listOfArticle.containsKey(articleId) || !pricedArticles.add(articleId)) return;
        listId = listOfArticle[articleId] as String;
      } else {
        // An empty list id meant "entered from the calculator of all lists".
        final given = map['id_list'] as String?;
        listId = given == null || given.isEmpty ? null : given;
        if (listId != null && !listIds.contains(listId)) return;
      }
      await txn.insert('prices', {
        'id': uuid.v4(),
        'list_id': listId,
        'article_id': linked ? map['id_article'] : null,
        'cents': (map['price'] as num).round(),
      });
      report.prices++;
    }

    for (final map in _decodeStore(data.prices, report)) {
      await _attempt(report, () => insert(map, linked: true));
    }
    for (final map in _decodeStore(data.manualPrices, report)) {
      await _attempt(report, () => insert(map, linked: false));
    }
  }

  static AppSettings _settings(LegacyData data) => AppSettings.fromLegacyMap({
    'theme': data.theme?['theme_mode'],
    'route': data.startRoute?['setting_router'],
    'category': data.categoryPosition?['setting_default_category_position'],
    'calculator': data.calculator?['setting_enable_calculator'] ?? 1,
    'lang': data.language,
  });
}
