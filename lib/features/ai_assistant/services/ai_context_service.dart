import '../../../core/constants/app_constants.dart';
import '../../../shared/models/debt_model.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/models/sale_model.dart';
import '../../../shared/repositories/customer_repository.dart';
import '../../../shared/repositories/debt_repository.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/sale_repository.dart';
import '../models/ai_context.dart';

/// Gathers a live [AiContext] snapshot from the existing Drift repositories.
///
/// Results are cached for [_cacheDuration] so rapid assistant messages
/// do not hammer the database. Call [invalidate] to force a fresh read.
class AiContextService {
  AiContextService._();
  static final AiContextService instance = AiContextService._();

  final _productRepo = ProductRepository();
  final _saleRepo = SaleRepository();
  final _debtRepo = DebtRepository();
  final _customerRepo = CustomerRepository();

  static const _cacheDuration = Duration(seconds: 30);

  AiContext? _cached;
  DateTime? _cachedAt;

  /// Returns a fresh [AiContext], or a cached one if captured within
  /// [_cacheDuration]. Uses [Future.wait] so all queries run in parallel.
  Future<AiContext> buildContext() async {
    if (_cached != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheDuration) {
      return _cached!;
    }

    // All repository calls run concurrently — no sequential blocking.
    final results = await Future.wait<dynamic>([
      _saleRepo.getTodayRevenue(),      // [0] double
      _saleRepo.getTodayProfit(),       // [1] double
      _productRepo.getInventoryCount(), // [2] int
      _productRepo.getLowStockCount(),  // [3] int
      _productRepo.getAllProducts(),    // [4] List<ProductModel>
      _saleRepo.getRecentSales(),       // [5] List<SaleModel>
      _customerRepo.getCustomers(),     // [6] List<UserModel>
      _debtRepo.getDebts(),             // [7] List<DebtModel>
    ]);

    final allProducts = results[4] as List<ProductModel>;
    final allDebts = results[7] as List<DebtModel>;

    final lowStockProducts = allProducts
        .where((p) => p.isActive && p.quantity <= AppConstants.lowStockThreshold)
        .toList();

    final unpaidDebts =
        allDebts.where((d) => d.status != DebtStatus.paid).toList();
    final totalOutstanding =
        unpaidDebts.fold(0.0, (sum, d) => sum + d.remaining);

    final ctx = AiContext(
      todayRevenue: results[0] as double,
      todayProfit: results[1] as double,
      inventoryCount: results[2] as int,
      lowStockCount: results[3] as int,
      lowStockProducts: lowStockProducts,
      recentSales: results[5] as List<SaleModel>,
      customerCount: (results[6] as List<dynamic>).length,
      totalOutstandingDebt: totalOutstanding,
      unpaidDebtCount: unpaidDebts.length,
      capturedAt: DateTime.now(),
    );

    _cached = ctx;
    _cachedAt = ctx.capturedAt;
    return ctx;
  }

  /// Clears the cache so the next [buildContext] call reads fresh data.
  void invalidate() {
    _cached = null;
    _cachedAt = null;
  }
}
