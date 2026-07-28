import '../models/ai_context.dart';
import 'ai_provider.dart';

/// A fully offline, rule-based [AiProvider].
///
/// Responds using real business data from [AiContext]. Supports both English
/// and Arabic (RTL). Also executes agent commands (add product, add debt, etc.)
/// by returning structured action prompts the UI can interpret.
class RuleBasedProvider implements AiProvider {
  const RuleBasedProvider();

  @override
  String get name => 'RuleBased';

  @override
  bool get isAvailable => true;

  @override
  Future<String> respond(String userMessage, AiContext ctx, {bool isArabic = false}) async {
    return _match(userMessage.trim(), ctx, isArabic);
  }

  String _match(String raw, AiContext ctx, bool isAr) {
    if (raw == '__init__') {
      return isAr
          ? 'مرحباً! 👋 أنا مساعد متجرك الذكي — يعمل بدون إنترنت.\n\nيمكنني مساعدتك في:\n• مبيعات وأرباح اليوم\n• تنبيهات المخزون المنخفض\n• ملخص الديون\n• أعداد العملاء والمنتجات\n\nماذا تريد أن تعرف؟'
          : 'Hello! 👋 I\'m your AI store assistant — running fully offline.\n\nI can help you with:\n• Today\'s sales & profit\n• Low stock and restock alerts\n• Outstanding debt summary\n• Customer and inventory counts\n\nWhat would you like to know?';
    }

    final isArabicInput = RegExp(r'[\u0600-\u06FF]').hasMatch(raw);
    final useAr = isAr || isArabicInput;
    final q = raw.toLowerCase();

    // ── Add Product ──
    if (_matchesAddProduct(raw, q, useAr)) {
      return _handleAddProduct(raw, useAr);
    }

    // ── Add Debt ──
    if (_matchesAddDebt(raw, q, useAr)) {
      return _handleAddDebt(raw, useAr);
    }

    // ── Search ──
    if (_matchesSearch(raw, q, useAr)) {
      return _handleSearch(raw, useAr);
    }

    // ── Profit ──
    if (q.contains('profit') || raw.contains('ربح') || raw.contains('ارباح') || raw.contains('أرباح')) {
      final tx = ctx.todayTransactionCount;
      final txLabel = tx > 0
          ? (useAr ? ' من $tx معاملة' : ' from $tx transaction${tx == 1 ? '' : 's'}')
          : '';
      return useAr
          ? 'ربح اليوم: ${_fmt(ctx.todayProfit)} ريال$txLabel.'
          : "Today's profit is YER ${_fmt(ctx.todayProfit)}$txLabel.";
    }

    // ── Revenue / sales summary ──
    if (q.contains('revenue') || q.contains('sales') || q.contains('summary') ||
        q.contains('how much') || raw.contains('مبيعات') || raw.contains('إيرادات')) {
      final tx = ctx.todayTransactionCount;
      final txLabel = tx > 0
          ? (useAr ? ' عبر $tx معاملة' : ' across $tx transaction${tx == 1 ? '' : 's'}')
          : '';
      return useAr
          ? 'إيرادات اليوم: ${_fmt(ctx.todayRevenue)} ريال$txLabel.\nالربح: ${_fmt(ctx.todayProfit)} ريال.'
          : "Today's revenue: YER ${_fmt(ctx.todayRevenue)}$txLabel.\nProfit: YER ${_fmt(ctx.todayProfit)}.";
    }

    // ── Low stock / restock ──
    if (q.contains('stock') || q.contains('order') || q.contains('restock') ||
        q.contains('low') || raw.contains('مخزون') || raw.contains('طلب') || raw.contains('ناقص')) {
      if (ctx.lowStockProducts.isEmpty) {
        return useAr
            ? '✅ جميع المنتجات بمخزون كافٍ. لا حاجة للطلب الآن.'
            : '✅ All products are well-stocked. No restocking needed right now.';
      }
      final list = ctx.lowStockProducts
          .take(5)
          .map((p) => '• ${p.name} (${p.quantity} ${useAr ? 'متبقي' : 'left'})')
          .join('\n');
      final more = ctx.lowStockCount > 5
          ? (useAr ? '\n…و ${ctx.lowStockCount - 5} منتج آخر.' : '\n…and ${ctx.lowStockCount - 5} more.')
          : '';
      return useAr
          ? '⚠️ ${ctx.lowStockCount} منتج تحتاج إعادة طلب:\n$list$more\n\nافتح المخزون للتفاصيل.'
          : '⚠️ ${ctx.lowStockCount} product${ctx.lowStockCount == 1 ? '' : 's'} need${ctx.lowStockCount == 1 ? 's' : ''} restocking:\n$list$more\n\nOpen Inventory for full details.';
    }

    // ── Debt ──
    if (q.contains('debt') || q.contains('owe') || q.contains('credit') ||
        raw.contains('دين') || raw.contains('ديون')) {
      if (ctx.unpaidDebtCount == 0) {
        return useAr
            ? '✅ لا توجد ديون مستحقة. جميع الحسابات خالية.'
            : '✅ No outstanding debts. All accounts are clear.';
      }
      return useAr
          ? 'ديون مستحقة: ${_fmt(ctx.totalOutstandingDebt)} ريال عبر ${ctx.unpaidDebtCount} عميل.\n\nافتح الديون للتفاصيل.'
          : 'Outstanding debt: YER ${_fmt(ctx.totalOutstandingDebt)} across ${ctx.unpaidDebtCount} customer${ctx.unpaidDebtCount == 1 ? '' : 's'}.\n\nOpen Debts to see full details.';
    }

    // ── Customers ──
    if (q.contains('customer') || raw.contains('عميل') || raw.contains('عملاء')) {
      return useAr
          ? 'لديك ${ctx.customerCount} عميل مسجل في قاعدة البيانات.'
          : 'You have ${ctx.customerCount} registered customer${ctx.customerCount == 1 ? '' : 's'} in the database.';
    }

    // ── Inventory / products ──
    if (q.contains('inventory') || q.contains('product') || raw.contains('منتج') || raw.contains('مخزن')) {
      final stockNote = ctx.lowStockCount > 0
          ? (useAr ? '⚠️ ${ctx.lowStockCount} منها تحتاج إعادة طلب.' : '⚠️ ${ctx.lowStockCount} of them need restocking.')
          : (useAr ? '✅ جميع المنتجات بمخزون كافٍ.' : '✅ All products are well-stocked.');
      return useAr
          ? 'مخزونك يحتوي على ${ctx.inventoryCount} منتج.\n$stockNote'
          : 'Your inventory has ${ctx.inventoryCount} product${ctx.inventoryCount == 1 ? '' : 's'}.\n$stockNote';
    }

    // ── Reports ──
    if (q.contains('report') || q.contains('analytics') || q.contains('summary') ||
        raw.contains('تقرير') || raw.contains('تقارير')) {
      return useAr
          ? '📊 تقرير اليوم:\n\nالإيرادات: ${_fmt(ctx.todayRevenue)} ريال\nالربح: ${_fmt(ctx.todayProfit)} ريال\nعدد المنتجات: ${ctx.inventoryCount}\nمخزون منخفض: ${ctx.lowStockCount}\nديون مستحقة: ${_fmt(ctx.totalOutstandingDebt)} ريال'
          : '📊 Today\'s Report:\n\nRevenue: YER ${_fmt(ctx.todayRevenue)}\nProfit: YER ${_fmt(ctx.todayProfit)}\nProducts: ${ctx.inventoryCount}\nLow stock: ${ctx.lowStockCount}\nOutstanding debt: YER ${_fmt(ctx.totalOutstandingDebt)}';
    }

    // ── Default help ──
    return useAr
        ? 'يمكنني مساعدتك في:\n• الأرباح والإيرادات\n• تنبيهات المخزون\n• ملخص الديون\n• أعداد العملاء والمنتجات\n\nجرّب: "كم ربحت اليوم؟" أو "ما المنتجات التي تحتاج طلب؟"'
        : 'I can help you with:\n• Today\'s profit and revenue\n• Low stock and restock alerts\n• Outstanding debt overview\n• Customer and inventory counts\n\nTry asking: "How much profit did I make today?" or "What products need restocking?"';
  }

  // ── Command matchers ──
  bool _matchesAddProduct(String raw, String q, bool isAr) {
    if (isAr) return raw.contains('أضف منتج') || raw.contains('اضف منتج') || raw.contains('إضافة منتج');
    return q.contains('add product') || q.contains('add item') || q.contains('create product');
  }

  bool _matchesAddDebt(String raw, String q, bool isAr) {
    if (isAr) return raw.contains('أضف دين') || raw.contains('اضف دين') || raw.contains('إضافة دين');
    return q.contains('add debt') || q.contains('create debt');
  }

  bool _matchesSearch(String raw, String q, bool isAr) {
    if (isAr) return raw.contains('بحث') || raw.contains('ابحث') || raw.contains('دور');
    return q.contains('search') || q.contains('find ');
  }

  // ── Command handlers (return guidance for now) ──
  String _handleAddProduct(String raw, bool isAr) {
    final nameMatch = RegExp(isAr ? r'منتج\s+(\S+)' : r'product\s+(.+?)(?:\s+price|\s+qty|\s+quantity|\s*\$)', caseSensitive: false).firstMatch(raw);
    final priceMatch = RegExp(isAr ? r'سعر(?:ه)?\s+(\d+)' : r'price\s+(?:of\s+)?(\d+)', caseSensitive: false).firstMatch(raw);
    final qtyMatch = RegExp(isAr ? r'كمية\s+(\d+)' : r'(?:qty|quantity)\s+(\d+)', caseSensitive: false).firstMatch(raw);
    final name = nameMatch?.group(1)?.trim() ?? (isAr ? 'منتج جديد' : 'New Product');
    final price = priceMatch != null ? priceMatch.group(1)! : '0';
    final qty = qtyMatch != null ? qtyMatch.group(1)! : '1';
    return isAr
        ? 'لإضافة منتج "$name" بسعر $price ريال وكمية $qty، افتح شاشة المخزون واضغط زر الإضافة.'
        : 'To add product "$name" at price $price YER with quantity $qty, open the Inventory screen and tap the add button.';
  }

  String _handleAddDebt(String raw, bool isAr) {
    final nameMatch = RegExp(isAr ? r'للعميل\s+(\S+)' : r'for\s+customer\s+(\S+)', caseSensitive: false).firstMatch(raw);
    final amountMatch = RegExp(r'(\d{3,})').firstMatch(raw);
    final name = nameMatch?.group(1)?.trim() ?? (isAr ? 'عميل' : 'Customer');
    final amount = amountMatch != null ? amountMatch.group(1)! : '0';
    return isAr
        ? 'لإضافة دين للعميل "$name" بمبلغ $amount ريال، افتح شاشة الديون.'
        : 'To add debt for customer "$name" with amount $amount YER, open the Debts screen.';
  }

  String _handleSearch(String raw, bool isAr) {
    final queryMatch = RegExp(isAr ? r'(?:بحث|دور)\s+(.+)' : r'(?:search|find)\s+(.+)', caseSensitive: false).firstMatch(raw);
    final query = queryMatch?.group(1)?.trim() ?? '';
    if (query.isEmpty) {
      return isAr ? 'اكتب اسم المنتج للبحث.' : 'Type a product name to search.';
    }
    return isAr
        ? 'ابحث عن "$query" في شاشة المخزون.'
        : 'Search for "$query" in the Inventory screen.';
  }

  String _fmt(double v) {
    return v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  }
}
