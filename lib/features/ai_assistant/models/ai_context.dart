import '../../../shared/models/product_model.dart';
import '../../../shared/models/sale_model.dart';

/// A point-in-time snapshot of the store's business state.
///
/// Built by [AiContextService] from the existing Drift repositories.
/// Passed to every [AiProvider] so providers never query the database
/// themselves — they only read from this immutable snapshot.
class AiContext {
  final double todayRevenue;
  final double todayProfit;
  final int inventoryCount;
  final int lowStockCount;

  /// Products whose quantity is at or below the low-stock threshold.
  final List<ProductModel> lowStockProducts;

  /// The most recent sales (up to the repository default limit).
  final List<SaleModel> recentSales;

  final int customerCount;

  /// Sum of [DebtModel.remaining] for all non-paid debts.
  final double totalOutstandingDebt;

  /// Number of debts whose status is not [DebtStatus.paid].
  final int unpaidDebtCount;

  /// Wall-clock time at which this snapshot was captured.
  final DateTime capturedAt;

  const AiContext({
    required this.todayRevenue,
    required this.todayProfit,
    required this.inventoryCount,
    required this.lowStockCount,
    required this.lowStockProducts,
    required this.recentSales,
    required this.customerCount,
    required this.totalOutstandingDebt,
    required this.unpaidDebtCount,
    required this.capturedAt,
  });

  /// Number of today's sales found in [recentSales].
  int get todayTransactionCount =>
      recentSales.where((s) => _isToday(s.createdAt)).length;

  static bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }
}
