import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shopping_list/core/database/app_database.dart';

/// A fresh in-memory database with the app schema.
Future<Database> openTestDatabase() {
  sqfliteFfiInit();
  return AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
}
