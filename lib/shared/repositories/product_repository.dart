import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../shared/models/product_model.dart';
import 'repository_exceptions.dart';

class ProductRepository {
  final AppDatabase _db = AppDatabase.instance;

  /// Returns a reactive stream of all products, ordered by creation date
  /// (newest first). The stream emits a new list whenever the database changes,
  /// enabling the UI to refresh automatically without manual reloads.
  Stream<List<ProductModel>> watchAllProducts() {
    return (_db.select(_db.products)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  Future<List<ProductModel>> getAllProducts({String? query}) async {
    try {
      final rows = await (_db.select(_db.products)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

      final products = rows.map(_mapRow).toList();

      if (query == null || query.trim().isEmpty) return products;
      final normalized = query.toLowerCase();
      return products.where((product) {
        final haystack = '${product.name} ${product.category} ${product.barcode ?? ''}'.toLowerCase();
        return haystack.contains(normalized);
      }).toList();
    } catch (e) {
      throw DatabaseException('Unable to load products: $e');
    }
  }

  Future<ProductModel> createProduct({
    required String name,
    required String category,
    required double purchasePrice,
    required double sellingPrice,
    required int quantity,
    String? barcode,
    String? description,
    String? branchId,
  }) async {
    _validateProduct(
      name: name,
      category: category,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      quantity: quantity,
      barcode: barcode,
    );

    try {
      if (barcode != null && barcode.trim().isNotEmpty) {
        final duplicate = await (_db.select(_db.products)
              ..where((tbl) => tbl.barcode.equals(barcode.trim())))
            .getSingleOrNull();
        if (duplicate != null) {
          throw ValidationException('A product with this barcode already exists.');
        }
      }

      final now = DateTime.now();
      final entity = ProductsCompanion(
        id: Value(Uuid().v4()),
        name: Value(name.trim()),
        category: Value(category.trim()),
        purchasePrice: Value(purchasePrice),
        sellingPrice: Value(sellingPrice),
        quantity: Value(quantity),
        barcode: Value(barcode?.trim()),
        description: Value(description?.trim()),
        branchId: Value(branchId?.trim()),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      await _db.into(_db.products).insert(entity);
      final row = await (_db.select(_db.products)
            ..where((tbl) => tbl.id.equals(entity.id.value)))
          .getSingle();
      return _mapRow(row);
    } catch (e) {
      if (e is ValidationException || e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Unable to create product: $e');
    }
  }

  Future<ProductModel> updateProduct({
    required String id,
    required String name,
    required String category,
    required double purchasePrice,
    required double sellingPrice,
    required int quantity,
    String? barcode,
    String? description,
    String? branchId,
  }) async {
    _validateProduct(
      name: name,
      category: category,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      quantity: quantity,
      barcode: barcode,
    );

    try {
      final existing = await (_db.select(_db.products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (existing == null) {
        throw ValidationException('Product not found.');
      }

      if (barcode != null && barcode.trim().isNotEmpty) {
        final duplicate = await (_db.select(_db.products)
              ..where((tbl) => tbl.barcode.equals(barcode.trim()) & tbl.id.isNotValue(id)))
            .getSingleOrNull();
        if (duplicate != null) {
          throw ValidationException('A product with this barcode already exists.');
        }
      }

      final now = DateTime.now();
      final companion = ProductsCompanion(
        name: Value(name.trim()),
        category: Value(category.trim()),
        purchasePrice: Value(purchasePrice),
        sellingPrice: Value(sellingPrice),
        quantity: Value(quantity),
        barcode: Value(barcode?.trim()),
        description: Value(description?.trim()),
        branchId: Value(branchId?.trim()),
        updatedAt: Value(now),
      );

      await (_db.update(_db.products)..where((tbl) => tbl.id.equals(id))).write(companion);

      final row = await (_db.select(_db.products)..where((tbl) => tbl.id.equals(id))).getSingle();
      return _mapRow(row);
    } catch (e) {
      if (e is ValidationException || e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Unable to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final deleted = await (_db.delete(_db.products)..where((tbl) => tbl.id.equals(id))).go();
      if (deleted == 0) {
        throw ValidationException('Product not found.');
      }
    } catch (e) {
      if (e is ValidationException || e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Unable to delete product: $e');
    }
  }

  Future<int> getInventoryCount() async {
    try {
      final rows = await (_db.select(_db.products)).get();
      return rows.length;
    } catch (e) {
      throw DatabaseException('Unable to load inventory count: $e');
    }
  }

  Future<int> getLowStockCount() async {
    try {
      final rows = await (_db.select(_db.products)
            ..where((tbl) => tbl.quantity.isSmallerThanValue(11) & tbl.quantity.isBiggerThanValue(0)))
          .get();
      return rows.length;
    } catch (e) {
      throw DatabaseException('Unable to load low stock count: $e');
    }
  }

  Future<int> getCurrentInventoryQuantity() async {
    try {
      final rows = await (_db.select(_db.products)).get();
      return rows.fold<int>(0, (sum, row) => sum + row.quantity);
    } catch (e) {
      throw DatabaseException('Unable to load inventory quantity: $e');
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final row = await (_db.select(_db.products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (row == null) return null;
      return _mapRow(row);
    } catch (e) {
      throw DatabaseException('Unable to load product: $e');
    }
  }

  ProductModel _mapRow(Product row) {
    return ProductModel(
      id: row.id,
      name: row.name,
      category: row.category,
      purchasePrice: row.purchasePrice,
      sellingPrice: row.sellingPrice,
      quantity: row.quantity,
      barcode: row.barcode,
      imageUrl: row.imageUrl,
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isActive: row.isActive,
      branchId: row.branchId,
    );
  }

  void _validateProduct({
    required String name,
    required String category,
    required double purchasePrice,
    required double sellingPrice,
    required int quantity,
    String? barcode,
  }) {
    if (name.trim().isEmpty) {
      throw ValidationException('Product name is required.');
    }
    if (category.trim().isEmpty) {
      throw ValidationException('Category is required.');
    }
    if (purchasePrice < 0) {
      throw ValidationException('Purchase price cannot be negative.');
    }
    if (sellingPrice < 0) {
      throw ValidationException('Selling price cannot be negative.');
    }
    if (quantity < 0) {
      throw ValidationException('Quantity cannot be negative.');
    }
    if (barcode != null && barcode.trim().isNotEmpty && barcode.trim().length < 2) {
      throw ValidationException('Barcode must be at least 2 characters.');
    }
  }
}
