import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../shared/models/product_model.dart';
import '../../shared/models/sale_model.dart';
import 'product_repository.dart';
import 'repository_exceptions.dart';

/// Data class for daily revenue/profit chart data.
class DailyRevenueProfit {
  final DateTime date;
  final double revenue;
  final double profit;
  const DailyRevenueProfit({required this.date, required this.revenue, required this.profit});
}

/// Data class for best-selling product entries.
class BestSellerEntry {
  final String productName;
  final double revenue;
  final int units;
  const BestSellerEntry({required this.productName, required this.revenue, required this.units});
}

/// Data class for category breakdown pie chart.
class CategoryShare {
  final String category;
  final double percentage;
  const CategoryShare({required this.category, required this.percentage});
}

class SaleRepository {
  final AppDatabase _db = AppDatabase.instance;
  final ProductRepository _products = ProductRepository();

  Future<SaleModel> createSale({
    required List<ProductModel> items,
    required double discount,
    required String workerId,
    String? customerId,
    String? customerName,
    String? branchId,
    String paymentMethod = 'cash',
  }) async {
    if (items.isEmpty) {
      throw ValidationException('Add at least one product to complete the sale.');
    }
    if (discount < 0) {
      throw ValidationException('Discount cannot be negative.');
    }

    try {
      final subtotal = items.fold<double>(0, (sum, item) => sum + (item.sellingPrice * item.quantity));
      final total = (subtotal - discount).clamp(0, double.infinity).toDouble();

      final saleId = Uuid().v4();
      final now = DateTime.now();

      await _db.transaction(() async {
        await _db.into(_db.sales).insert(SalesCompanion(
          id: Value(saleId),
          subtotal: Value(subtotal),
          discount: Value(discount),
          total: Value(total),
          customerId: Value(customerId),
          customerName: Value(customerName),
          workerId: Value(workerId),
          branchId: Value(branchId),
          createdAt: Value(now),
          paymentMethod: Value(paymentMethod),
        ));

        for (final item in items) {
          final quantity = item.quantity;
          if (quantity <= 0) {
            throw ValidationException('Quantity must be greater than zero.');
          }

          final product = await (_db.select(_db.products)
                ..where((tbl) => tbl.id.equals(item.id)))
              .getSingleOrNull();
          if (product == null) {
            throw ValidationException('Product "${item.name}" not found.');
          }
          if (product.quantity < quantity) {
            throw ValidationException(
                'Insufficient stock for "${item.name}". Available: ${product.quantity}, Requested: $quantity.');
          }

          await _db.into(_db.saleItems).insert(SaleItemsCompanion(
            id: Value(Uuid().v4()),
            saleId: Value(saleId),
            productId: Value(item.id),
            productName: Value(item.name),
            quantity: Value(quantity),
            unitPrice: Value(item.sellingPrice),
            totalPrice: Value(item.sellingPrice * quantity),
          ));

          await (_db.update(_db.products)
                ..where((tbl) => tbl.id.equals(item.id)))
              .write(ProductsCompanion(
            quantity: Value(product.quantity - quantity),
            updatedAt: Value(now),
          ));
        }
      });

      return SaleModel(
        id: saleId,
        items: items.map((p) => SaleItemModel(
              productId: p.id,
              productName: p.name,
              quantity: p.quantity,
              unitPrice: p.sellingPrice,
              totalPrice: p.sellingPrice * p.quantity,
            )).toList(),
        subtotal: subtotal,
        discount: discount,
        total: total,
        customerId: customerId,
        customerName: customerName,
        workerId: workerId,
        branchId: branchId,
        createdAt: now,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      if (e is ValidationException || e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Unable to create sale: $e');
    }
  }

  /// Watches the most recent [limit] sales as a reactive stream.
  ///
  /// Emits a new list automatically whenever the sales table changes,
  /// so the UI refreshes without manual reloads.
  Stream<List<SaleModel>> watchRecentSales({int limit = 50}) {
    return (_db.select(_db.sales)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch()
        .asyncMap((rows) async {
      final result = <SaleModel>[];
      for (final row in rows) {
        final saleItems = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(row.id)))
            .get();
        result.add(SaleModel(
          id: row.id,
          items: saleItems
              .map((item) => SaleItemModel(
                    productId: item.productId,
                    productName: item.productName,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    totalPrice: item.totalPrice,
                  ))
              .toList(),
          subtotal: row.subtotal,
          discount: row.discount,
          total: row.total,
          customerId: row.customerId,
          customerName: row.customerName,
          workerId: row.workerId,
          branchId: row.branchId,
          createdAt: row.createdAt,
          paymentMethod: row.paymentMethod,
        ));
      }
      return result;
    });
  }

  Future<List<SaleModel>> getRecentSales() async {
    try {
      final rows = await (_db.select(_db.sales)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(10))
          .get();
      final items = <SaleModel>[];
      for (final row in rows) {
        final saleItems = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(row.id)))
            .get();
        items.add(SaleModel(
          id: row.id,
          items: saleItems.map((item) => SaleItemModel(
                productId: item.productId,
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                totalPrice: item.totalPrice,
              )).toList(),
          subtotal: row.subtotal,
          discount: row.discount,
          total: row.total,
          customerId: row.customerId,
          customerName: row.customerName,
          workerId: row.workerId,
          branchId: row.branchId,
          createdAt: row.createdAt,
          paymentMethod: row.paymentMethod,
        ));
      }
      return items;
    } catch (e) {
      throw DatabaseException('Unable to load sales: $e');
    }
  }

  Future<double> getTodayRevenue() async {
    try {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 1));
      final rows = await (_db.select(_db.sales)
            ..where((tbl) => tbl.createdAt.isBetweenValues(start, end)))
          .get();
      return rows.fold<double>(0, (sum, row) => sum + row.total);
    } catch (e) {
      throw DatabaseException('Unable to load today revenue: $e');
    }
  }

  Future<double> getTodayProfit() async {
    try {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 1));
      final rows = await (_db.select(_db.sales)
            ..where((tbl) => tbl.createdAt.isBetweenValues(start, end)))
          .get();
      double profit = 0;
      for (final row in rows) {
        final items = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(row.id)))
            .get();
        for (final item in items) {
          final product = await _products.getProductById(item.productId);
          if (product != null) {
            profit += item.totalPrice - (product.purchasePrice * item.quantity);
          }
        }
      }
      return profit;
    } catch (e) {
      throw DatabaseException('Unable to load today profit: $e');
    }
  }

  // ── Analytics ──────────────────────────────────────────────────────────────

  /// Returns total revenue for the inclusive period [from, to).
  Future<double> getRevenueForPeriod(DateTime from, DateTime to) async {
    try {
      final rows = await (_db.select(_db.sales)
            ..where((tbl) => tbl.createdAt.isBetweenValues(from, to)))
          .get();
      return rows.fold<double>(0, (sum, row) => sum + row.total);
    } catch (e) {
      throw DatabaseException('Unable to load revenue: $e');
    }
  }

  /// Returns total profit (revenue − COGS) for the period [from, to).
  Future<double> getProfitForPeriod(DateTime from, DateTime to) async {
    try {
      final sales = await (_db.select(_db.sales)
            ..where((tbl) => tbl.createdAt.isBetweenValues(from, to)))
          .get();
      double profit = 0;
      for (final sale in sales) {
        final items = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(sale.id)))
            .get();
        for (final item in items) {
          final product = await _products.getProductById(item.productId);
          if (product != null) {
            profit += item.totalPrice - (product.purchasePrice * item.quantity);
          }
        }
      }
      return profit;
    } catch (e) {
      throw DatabaseException('Unable to load profit: $e');
    }
  }

  /// Returns the number of transactions for the period [from, to).
  Future<int> getTransactionCountForPeriod(DateTime from, DateTime to) async {
    try {
      final rows = await (_db.select(_db.sales)
            ..where((tbl) => tbl.createdAt.isBetweenValues(from, to)))
          .get();
      return rows.length;
    } catch (e) {
      throw DatabaseException('Unable to load transaction count: $e');
    }
  }

  /// Returns best-selling products by revenue for the period [from, to).
  ///
  /// Each map contains: 'name' (String), 'revenue' (double), 'units' (int).
  Future<List<Map<String, dynamic>>> getBestSellersForPeriod(
    DateTime from,
    DateTime to, {
    int limit = 5,
  }) async {
    try {
      final sales = await (_db.select(_db.sales)
            ..where((tbl) => tbl.createdAt.isBetweenValues(from, to)))
          .get();

      final Map<String, Map<String, dynamic>> totals = {};
      for (final sale in sales) {
        final items = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(sale.id)))
            .get();
        for (final item in items) {
          totals.update(
            item.productId,
            (existing) => {
              'name': existing['name'],
              'revenue': (existing['revenue'] as double) + item.totalPrice,
              'units': (existing['units'] as int) + item.quantity,
            },
            ifAbsent: () => {
              'name': item.productName,
              'revenue': item.totalPrice,
              'units': item.quantity,
            },
          );
        }
      }

      final sorted = totals.values.toList()
        ..sort((a, b) =>
            (b['revenue'] as double).compareTo(a['revenue'] as double));
      return sorted.take(limit).toList();
    } catch (e) {
      throw DatabaseException('Unable to load best sellers: $e');
    }
  }

  /// Returns daily revenue and profit for the last [days] days (for charts).
  ///
  /// Each map contains: 'day' (int, 0 = oldest), 'revenue' (double),
  /// 'profit' (double).
  Future<List<Map<String, dynamic>>> getDailyRevenueSeries(int days) async {
    try {
      final now = DateTime.now();
      final series = <Map<String, dynamic>>[];
      for (int i = days - 1; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day - i);
        final dayEnd = day.add(const Duration(days: 1));
        final rev = await getRevenueForPeriod(day, dayEnd);
        final prof = await getProfitForPeriod(day, dayEnd);
        series.add({
          'day': (days - 1 - i).toDouble(),
          'revenue': rev,
          'profit': prof,
        });
      }
      return series;
    } catch (e) {
      throw DatabaseException('Unable to load daily series: $e');
    }
  }

  // ── Reactive stream helpers for analytics UI ──────────────────────────────

  /// Reactive stream of daily revenue/profit for the last [days] days.
  Stream<List<DailyRevenueProfit>> watchDailyRevenueProfit({required int days}) {
    return _db.select(_db.sales).watch().asyncMap((_) async {
      final now = DateTime.now();
      final result = <DailyRevenueProfit>[];
      for (int i = days - 1; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day - i);
        final dayEnd = day.add(const Duration(days: 1));
        final rev = await getRevenueForPeriod(day, dayEnd);
        final prof = await getProfitForPeriod(day, dayEnd);
        result.add(DailyRevenueProfit(date: day, revenue: rev, profit: prof));
      }
      return result;
    });
  }

  /// Reactive stream of best-selling products for the last [days] days.
  Stream<List<BestSellerEntry>> watchBestSellers({required int days, int limit = 5}) {
    return _db.select(_db.sales).watch().asyncMap((_) async {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day - days);
      final raw = await getBestSellersForPeriod(from, now, limit: limit);
      return raw.map((e) => BestSellerEntry(
        productName: e['name'] as String,
        revenue: e['revenue'] as double,
        units: e['units'] as int,
      )).toList();
    });
  }

  /// Reactive stream of sales category breakdown for the last [days] days.
  Stream<List<CategoryShare>> watchCategoryBreakdown({required int days}) {
    return _db.select(_db.sales).watch().asyncMap((_) async {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day - days);
      final raw = await getCategoryBreakdownForPeriod(from, now);
      return raw.map((e) => CategoryShare(
        category: e['label'] as String,
        percentage: e['pct'] as double,
      )).toList();
    });
  }

  /// Returns sales grouped by product category for the period [from, to).
  ///
  /// Each map contains: 'label' (String), 'pct' (double, 0–100).
  Future<List<Map<String, dynamic>>> getCategoryBreakdownForPeriod(
    DateTime from,
    DateTime to,
  ) async {
    try {
      final sales = await (_db.select(_db.sales)
            ..where((tbl) => tbl.createdAt.isBetweenValues(from, to)))
          .get();

      final Map<String, double> totals = {};
      for (final sale in sales) {
        final items = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(sale.id)))
            .get();
        for (final item in items) {
          final product = await (_db.select(_db.products)
                ..where((tbl) => tbl.id.equals(item.productId)))
              .getSingleOrNull();
          final category = product?.category ?? 'Other';
          totals[category] = (totals[category] ?? 0) + item.totalPrice;
        }
      }

      final grandTotal = totals.values.fold<double>(0, (a, b) => a + b);
      if (grandTotal == 0) return [];

      final result = totals.entries
          .map((e) => {
                'label': e.key,
                'pct': (e.value / grandTotal) * 100,
              })
          .toList()
        ..sort(
            (a, b) => (b['pct'] as double).compareTo(a['pct'] as double));
      return result;
    } catch (e) {
      throw DatabaseException('Unable to load category breakdown: $e');
    }
  }
}
