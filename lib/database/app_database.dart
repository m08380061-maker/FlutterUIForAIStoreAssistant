import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/branches_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/debts_dao.dart';
import 'daos/employees_dao.dart';
import 'daos/inventory_movements_dao.dart';
import 'daos/products_dao.dart';
import 'daos/sales_dao.dart';
import 'daos/stores_dao.dart';
import 'tables/branches_table.dart';
import 'tables/customers_table.dart';
import 'tables/debts_table.dart';
import 'tables/employees_table.dart';
import 'tables/inventory_movements_table.dart';
import 'tables/products_table.dart';
import 'tables/sales_table.dart';
import 'tables/stores_table.dart';

part 'app_database.g.dart';

/// The single Drift database for the AI Store Assistant app.
///
/// All tables, DAOs, and migrations live here. The database is opened
/// with [NativeDatabase] which picks the correct SQLite backend for the
/// current platform (Android, iOS, macOS, Linux, Windows).
///
/// Usage via [ServiceLocator]:
/// ```dart
/// final db = ServiceLocator.database;
/// final products = await db.productsDao.getAll();
/// ```
///
/// Schema version history:
/// - **v1** — initial schema with 8 tables.
@DriftDatabase(
  tables: [
    Stores,
    Branches,
    Employees,
    Products,
    Sales,
    Customers,
    Debts,
    InventoryMovements,
  ],
  daos: [
    StoresDao,
    BranchesDao,
    EmployeesDao,
    ProductsDao,
    SalesDao,
    CustomersDao,
    DebtsDao,
    InventoryMovementsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates the database with the default platform SQLite backend.
  ///
  /// Pass a custom [executor] in tests to use an in-memory database:
  /// ```dart
  /// AppDatabase(NativeDatabase.memory())
  /// ```
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'ai_store_assistant_db.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // TODO(sync): add migration steps here when schema version increments.
        },
        beforeOpen: (details) async {
          // Enable foreign key enforcement for every connection.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
