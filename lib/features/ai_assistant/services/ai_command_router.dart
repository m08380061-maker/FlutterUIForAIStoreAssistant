import '../providers/ai_provider.dart';
import '../providers/llama_cpp_provider.dart';
import '../providers/rule_based_provider.dart';
import 'ai_context_service.dart';

/// Result returned by [AiCommandRouter.route].
/// [navRoute] is set when the message maps to an in-app navigation action.
class AiRouterResult {
  final String text;
  final String? navRoute;
  const AiRouterResult(this.text, {this.navRoute});
}

class AiCommandRouter {
  AiCommandRouter._();
  static final AiCommandRouter instance = AiCommandRouter._();

  final AiContextService _contextService = AiContextService.instance;

  final List<AiProvider> _providers = const [
    LlamaCppProvider(),
    RuleBasedProvider(),
  ];

  /// Maps a user message to a navigation route if it matches a known command.
  static String? _matchNavRoute(String message) {
    final m = message.trim().toLowerCase();

    // Live barcode scanner (cashier scan)
    if (_has(m, ['افتح المسح', 'ابدأ المسح', 'مسح الباركود', 'open scanner',
        'start scan', 'barcode scan', 'live scan'])) {
      return '/scanner/live';
    }
    // Add product
    if (_has(m, ['أضف منتج', 'إضافة منتج', 'منتج جديد', 'add product',
        'new product', 'إضافة سلعة'])) {
      return '/scanner';
    }
    // Debts
    if (_has(m, ['أنشئ دين', 'إضافة دين', 'ديون', 'add debt', 'new debt',
        'debts', 'debt'])) {
      return '/debts';
    }
    // Sales / invoice
    if (_has(m, ['اذهب إلى المبيعات', 'فاتورة', 'مبيعات', 'أنشئ فاتورة',
        'sales', 'invoice', 'checkout', 'new sale'])) {
      return '/sales';
    }
    // Analytics
    if (_has(m, ['افتح التحليل', 'تحليل', 'تقارير', 'analytics', 'reports',
        'statistics'])) {
      return '/analytics';
    }
    // Inventory
    if (_has(m, ['المخزون', 'المنتجات', 'inventory', 'products', 'stock'])) {
      return '/inventory';
    }
    // Marketing
    if (_has(m, ['تسويق', 'عروض', 'marketing', 'promotions'])) {
      return '/marketing';
    }
    // Branches
    if (_has(m, ['فروع', 'الفروع', 'branches'])) {
      return '/branches';
    }
    return null;
  }

  static bool _has(String haystack, List<String> needles) =>
      needles.any((n) => haystack.contains(n));

  Future<AiRouterResult> route(String message, {bool isArabic = false}) async {
    // Check for navigation commands first (works fully offline).
    final navRoute = _matchNavRoute(message);
    if (navRoute != null) {
      final confirmation = isArabic
          ? 'جارٍ الانتقال...'
          : 'Opening that for you...';
      return AiRouterResult(confirmation, navRoute: navRoute);
    }

    final context = await _contextService.buildContext();
    for (final provider in _providers) {
      if (provider.isAvailable) {
        final text = await provider.respond(message, context, isArabic: isArabic);
        return AiRouterResult(text);
      }
    }

    return AiRouterResult(
      isArabic
          ? 'لا أستطيع معالجة طلبك الآن. حاول مرة أخرى.'
          : 'I\'m unable to process your request right now. Please try again.',
    );
  }

  void invalidateContext() => _contextService.invalidate();
}
