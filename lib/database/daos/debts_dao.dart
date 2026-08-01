import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/debts_table.dart';

part 'debts_dao.g.dart';

/// Data Access Object for [Debts] table operations.
@DriftAccessor(tables: [Debts])
class DebtsDao extends DatabaseAccessor<AppDatabase> with _$DebtsDaoMixin {
  DebtsDao(super.db);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Watches all debts, newest first, as a reactive stream.
  Stream<List<Debt>> watchAll() =>
      (select(debts)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Returns all debts as a one-time snapshot.
  Future<List<Debt>> getAll() =>
      (select(debts)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Returns a single debt by its primary key, or `null` if not found.
  Future<Debt?> getById(int id) =>
      (select(debts)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Watches all debts for the given [customerId].
  Stream<List<Debt>> watchByCustomer(int customerId) =>
      (select(debts)..where((t) => t.customerId.equals(customerId))).watch();

  /// Watches debts where [remaining] is greater than zero (unpaid/partial).
  Stream<List<Debt>> watchUnpaid() =>
      (select(debts)..where((t) => t.remaining.isBiggerThanValue(0.0)))
          .watch();

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new debt and returns the generated row id.
  Future<int> insertOne(DebtsCompanion companion) =>
      into(debts).insert(companion);

  /// Replaces an existing debt row entirely.
  Future<bool> updateOne(Debt entity) => update(debts).replace(entity);

  /// Partially updates a debt identified by [id].
  Future<int> updateById(int id, DebtsCompanion companion) =>
      (update(debts)..where((t) => t.id.equals(id))).write(companion);

  /// Records a payment of [amount] against debt [id].
  ///
  /// Increments [paid] and decrements [remaining] atomically.
  Future<void> recordPayment(int id, double amount) async {
    final debt = await getById(id);
    if (debt == null) return;
    final newPaid = debt.paid + amount;
    final newRemaining = (debt.remaining - amount).clamp(0.0, debt.amount);
    await updateById(
      id,
      DebtsCompanion(
        paid: Value(newPaid),
        remaining: Value(newRemaining),
      ),
    );
  }

  /// Deletes the debt with the given [id]. Returns number of rows deleted.
  Future<int> deleteById(int id) =>
      (delete(debts)..where((t) => t.id.equals(id))).go();
}
