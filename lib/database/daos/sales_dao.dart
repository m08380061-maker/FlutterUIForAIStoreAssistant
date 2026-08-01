import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sales_table.dart';

part 'sales_dao.g.dart';

/// Data Access Object for [Sales] table operations.
@DriftAccessor(tables: [Sales])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Watches all sales, newest first.
  Stream<List<Sale>> watchAll() =>
      (select(sales)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Returns all sales as a one-time snapshot, newest first.
  Future<List<Sale>> getAll() =>
      (select(sales)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Returns a single sale by its primary key, or `null` if not found.
  Future<Sale?> getById(int id) =>
      (select(sales)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Returns all sales for the given [productId].
  Future<List<Sale>> getByProduct(int productId) =>
      (select(sales)..where((t) => t.productId.equals(productId))).get();

  /// Returns all sales processed by [employeeId].
  Future<List<Sale>> getByEmployee(int employeeId) =>
      (select(sales)..where((t) => t.employeeId.equals(employeeId))).get();

  /// Returns sales recorded within the inclusive date range [[from], [to]].
  Future<List<Sale>> getByDateRange(DateTime from, DateTime to) =>
      (select(sales)
            ..where(
              (t) => t.createdAt.isBetweenValues(from, to),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Watches sales recorded on the given calendar [day].
  Stream<List<Sale>> watchByDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(sales)
          ..where((t) => t.createdAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new sale and returns the generated row id.
  Future<int> insertOne(SalesCompanion companion) =>
      into(sales).insert(companion);

  /// Deletes the sale with the given [id]. Returns number of rows deleted.
  Future<int> deleteById(int id) =>
      (delete(sales)..where((t) => t.id.equals(id))).go();
}
