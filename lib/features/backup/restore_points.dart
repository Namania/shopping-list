import 'dart:convert';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/core/data/data_changes.dart';
import 'package:shopping_list/features/backup/data_dump.dart';
import 'package:shopping_list/features/settings/app_settings.dart';

/// Why a restore point was taken.
enum RestorePointReason { daily, beforeImport, beforeRestore }

class RestorePoint {
  final File file;
  final DateTime date;
  final RestorePointReason reason;

  const RestorePoint(this.file, this.date, this.reason);
}

/// Copies of the whole data kept on the phone, so a wrong import or restore
/// can be undone: one a day, and one before anything replaces data. Only
/// the [max] most recent are kept.
class RestorePoints {
  static const max = 7;

  /// A daily copy is skipped when another one is more recent than this.
  static const dailyEvery = Duration(hours: 20);

  final Database db;
  final DataChanges changes;
  final Directory directory;

  RestorePoints(this.db, this.changes, this.directory);

  /// Newest first. Files are named `<milliseconds>_<reason>.json`.
  Future<List<RestorePoint>> all() async {
    if (!await directory.exists()) return [];
    final points = <RestorePoint>[];
    await for (final entity in directory.list()) {
      final name = entity.uri.pathSegments.last;
      final match = RegExp(r'^(\d+)_(\w+)\.json$').firstMatch(name);
      final reason = RestorePointReason.values.where((r) => r.name == match?[2]).firstOrNull;
      if (entity is! File || match == null || reason == null) continue;
      points.add(RestorePoint(entity, DateTime.fromMillisecondsSinceEpoch(int.parse(match[1]!)), reason));
    }
    return points..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Copies the current data. A daily copy of no data is skipped; before an
  /// import it is kept, so undoing the import empties the data again.
  Future<RestorePoint?> take(RestorePointReason reason, {DateTime? now}) async {
    final dump = await DataDump.read(db);
    if (dump.isEmpty && reason == RestorePointReason.daily) return null;
    await directory.create(recursive: true);
    final date = now ?? DateTime.now();
    final file = File('${directory.path}/${date.millisecondsSinceEpoch}_${reason.name}.json');
    await file.writeAsString(jsonEncode(dump.toJson()));
    for (final old in (await all()).skip(max)) {
      await old.file.delete();
    }
    return RestorePoint(file, date, reason);
  }

  /// Takes the daily copy when the last one is old enough.
  Future<void> takeDailyIfDue({DateTime? now}) async {
    final date = now ?? DateTime.now();
    final latest = (await all()).firstOrNull;
    if (latest != null && date.difference(latest.date) < dailyEvery) return;
    await take(RestorePointReason.daily, now: date);
  }

  Future<DataDump> read(RestorePoint point) async =>
      DataDump.fromJson(jsonDecode(await point.file.readAsString()) as Map<String, dynamic>);

  /// Puts the data back as it was at [point] and returns the settings it
  /// held. The current data is saved first, so going back is undoable too,
  /// unless [saveCurrent] is false (undoing an import).
  Future<AppSettings?> restore(RestorePoint point, {bool saveCurrent = true}) async {
    final dump = await read(point);
    if (saveCurrent) await take(RestorePointReason.beforeRestore);
    await db.transaction(dump.restoreIn);
    changes.notify();
    return dump.settings;
  }
}
