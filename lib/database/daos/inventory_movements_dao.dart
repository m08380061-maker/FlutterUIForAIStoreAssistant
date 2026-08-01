import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/inventory_movements_table.dart';

part 'inventory_movements_dao.g.dart';

/// Data Access Object for [InventoryMovements] table operations.
///
/// Provides the full audit trail of stock changes.
@DriftAccessor(tables: [InventoryMovements])
class InventoryMovementsDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryMovementsDaoMixin {
  InventoryMovementsDao(super.db);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Watches all inventory movements, newest first.
  Stream<List<InventoryMovement>> watchAll() =>
      (select(inventoryMovements)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Returns all inventory movements as a one-time snapshot.
  Future<List<InventoryMovement>> getAll() =>
      (select(inventoryMovements)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Returns all movements for the given [productId].
  Future<List<InventoryMovement>> getByProduct(int productId) =>
      (select(inventoryMovements)
            ..where((t) => t.productId.equals(productId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Returns all movements of a specific [type] (`'in'`, `'out'`,
  /// or `'adjustment'`).
  Future<List<InventoryMovement>> getByType(String type) =>
      (select(inventoryMovements)..where((t) => t.type.equals(type))).get();

  /// Returns movements recorded within the inclusive date range
  /// [[from], [to]].
  Future<List<InventoryMovement>> getByDateRange(
    DateTime from,
    DateTime to,
  ) =>
      (select(inventoryMovements)
            ..where((t) => t.createdAt.isBetweenValues(from, to))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new movement record and returns the generated row id.
  Future<int> insertOne(InventoryMovementsCompanion companion) =>
      into(inventoryMovements).insert(companion);

  /// Deletes a movement record by [id]. Returns number of rows deleted.
  Future<int> deleteById(int id) =>
      (delete(inventoryMovements)..where((t) => t.id.equals(id))).go();
}
