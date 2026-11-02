# shopping_list

Flutter app to write shopping lists and keep loyalty cards, fully offline.

## Architecture

Everything lives in a local SQLite database (`sqflite`), opened once at
startup by [`lib/bootstrap.dart`](lib/bootstrap.dart).

```
lib/
  bootstrap.dart        opens the DB, migrates old data, loads the cubits
  app.dart              MaterialApp + router + theme
  core/
    database/           schema (app_database.dart), one-time migration of
                        the shared_preferences / hydrated_bloc data of 1.3.x
    data/               DataChanges bus + RepositoryCubit base class
    ui/                 shared widgets: CollectionPage, MovableList,
                        SwipeToDelete, form / confirm dialogs, bottom sheets
    pages/, router/, scanner/, theme/, utils/
  features/
    lists/              ShoppingList + Article, repository, cubit, pages
    categories/         Category, repository, cubit, page
    cards/              LoyaltyCard, repository, cubit, page, barcode view
    prices/             calculator amounts, repository, cubit, page
    settings/           AppSettings (stored in the DB), page, backup
    sharing/            QR / deep link payload, share and import sheets
```

Each feature follows the same shape:

- a **model** (immutable, `Equatable`, `toMap` for the share / backup
  format, which is kept compatible with older versions);
- a **repository** that is the only thing talking SQL;
- a **cubit** (`RepositoryCubit`) whose state is a snapshot of the table.
  Every write notifies `DataChanges`, and every cubit reloads on it, which
  keeps related tables (articles → categories, lists → cards, prices →
  articles) in sync without the cubits knowing each other;
- **pages / tiles / dialogs** built on the shared widgets in `core/ui`.

Foreign keys do the housekeeping: removing a category uncategorizes its
articles, removing a card unlinks its lists, removing a list or an article
removes their prices.

`shared_preferences` and `hydrated_bloc` are only used by
`core/database/legacy_sources.dart` to read the data of versions ≤ 1.3.x on
the first launch after the update; they can be dropped once that migration
is retired.

## Tests

```
flutter test
```

The data layer is tested against an in-memory SQLite database
(`sqflite_common_ffi`), including the migration of the 1.3.x stores.

## Deployment

1. Update `pubspec.yaml` (`version: name+code`) — the settings page reads it
   at runtime.
2. `flutter build aab` (Android) / `flutter build ipa` (iOS).
