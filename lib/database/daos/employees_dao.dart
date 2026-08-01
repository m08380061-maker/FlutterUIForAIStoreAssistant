import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/employees_table.dart';

part 'employees_dao.g.dart';

/// Data Access Object for [Employees] table operations.
@DriftAccessor(tables: [Employees])
class EmployeesDao extends DatabaseAccessor<AppDatabase>
    with _$EmployeesDaoMixin {
  EmployeesDao(super.db);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Watches all employees as a reactive stream.
  Stream<List<Employee>> watchAll() => select(employees).watch();

  /// Returns all employees as a one-time snapshot.
  Future<List<Employee>> getAll() => select(employees).get();

  /// Returns a single employee by their primary key, or `null` if not found.
  Future<Employee?> getById(int id) =>
      (select(employees)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Watches all employees assigned to the given [branchId].
  Stream<List<Employee>> watchByBranch(int branchId) =>
      (select(employees)..where((t) => t.branchId.equals(branchId))).watch();

  /// Returns all employees assigned to the given [branchId].
  Future<List<Employee>> getByBranch(int branchId) =>
      (select(employees)..where((t) => t.branchId.equals(branchId))).get();

  /// Returns all employees with the specified [role].
  Future<List<Employee>> getByRole(String role) =>
      (select(employees)..where((t) => t.role.equals(role))).get();

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new employee and returns the generated row id.
  Future<int> insertOne(EmployeesCompanion companion) =>
      into(employees).insert(companion);

  /// Replaces an existing employee row entirely.
  Future<bool> updateOne(Employee entity) =>
      update(employees).replace(entity);

  /// Partially updates an employee identified by [id].
  Future<int> updateById(int id, EmployeesCompanion companion) =>
      (update(employees)..where((t) => t.id.equals(id))).write(companion);

  /// Deletes the employee with the given [id]. Returns number of rows deleted.
  Future<int> deleteById(int id) =>
      (delete(employees)..where((t) => t.id.equals(id))).go();
}
