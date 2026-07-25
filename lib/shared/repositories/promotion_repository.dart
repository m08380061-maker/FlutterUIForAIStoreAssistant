import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../shared/models/promotion_model.dart';
import 'repository_exceptions.dart';

class PromotionRepository {
  final AppDatabase _db = AppDatabase.instance;

  /// Reactive stream — emits a new list whenever promotions change.
  Stream<List<PromotionModel>> watchPromotions() {
    return (_db.select(_db.promotions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  Future<PromotionModel> createPromotion({
    required String title,
    required String discount,
    required DateTime expiresAt,
  }) async {
    if (title.trim().isEmpty) {
      throw ValidationException('Promotion title is required.');
    }
    try {
      final now = DateTime.now();
      final id = const Uuid().v4();
      await _db.into(_db.promotions).insert(PromotionsCompanion(
            id: Value(id),
            title: Value(title.trim()),
            discount: Value(discount.trim()),
            isActive: const Value(true),
            expiresAt: Value(expiresAt),
            createdAt: Value(now),
          ));
      return PromotionModel(
        id: id,
        title: title.trim(),
        discount: discount.trim(),
        isActive: true,
        expiresAt: expiresAt,
        createdAt: now,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Unable to save promotion: $e');
    }
  }

  Future<void> togglePromotion(String id) async {
    try {
      final row = await (_db.select(_db.promotions)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) throw ValidationException('Promotion not found.');
      await (_db.update(_db.promotions)..where((t) => t.id.equals(id)))
          .write(PromotionsCompanion(isActive: Value(!row.isActive)));
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Unable to toggle promotion: $e');
    }
  }

  Future<void> deletePromotion(String id) async {
    try {
      final deleted = await (_db.delete(_db.promotions)
            ..where((t) => t.id.equals(id)))
          .go();
      if (deleted == 0) throw ValidationException('Promotion not found.');
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Unable to delete promotion: $e');
    }
  }

  PromotionModel _mapRow(Promotion row) => PromotionModel(
        id: row.id,
        title: row.title,
        discount: row.discount,
        isActive: row.isActive,
        expiresAt: row.expiresAt,
        createdAt: row.createdAt,
      );
}
