import '../models/ai_context.dart';
import 'ai_provider.dart';

/// A fully offline, rule-based [AiProvider].
///
/// Responds using real business data from [AiContext] — no hardcoded numbers,
/// no network requests. Always [isAvailable] so it acts as the final fallback
/// when no local model backend is loaded.
///
/// Extend this class or add a higher-priority provider to [AiCommandRouter]
/// when a local model (llama.cpp, ONNX Runtime, etc.) is ready.
class RuleBasedProvider implements AiProvider {
  const RuleBasedProvider();

  @override
  String get name => 'RuleBased';

  @override
  bool get isAvailable => true;

  @override
  Future<String> respond(String userMessage, AiContext ctx) async {
    // No network I/O — synchronous pattern match on lowercased input.
    return _match(userMessage.trim(), ctx);
  }

  String _match(String raw, AiContext ctx) {
    // Internal init trigger — produces the welcome message.
    if (raw == '__init__') {
      return 'Hello! 👋 I\'m your AI store assistant — running fully offline.\n\n'
          'I can help you with:\n'
          '• Today\'s sales & profit\n'
          '• Low stock and restock alerts\n'
          '• Outstanding debt summary\n'
          '• Customer and inventory counts\n\n'
          'What would you like to know?';
    }

    final q = raw.toLowerCase();

    // ── Profit ───────────────────────────────────────────────────────────────
    if (q.contains('profit')) {
      final tx = ctx.todayTransactionCount;
      final txLabel = tx > 0 ? ' from $tx transaction${tx == 1 ? '' : 's'}' : '';
      return "Today's profit is YER ${_fmt(ctx.todayProfit)}$txLabel.";
    }

    // ── Revenue / sales summary ──────────────────────────────────────────────
    if (q.contains('revenue') ||
        q.contains('sales') ||
        q.contains('summary') ||
        q.contains('how much')) {
      final tx = ctx.todayTransactionCount;
      final txLabel =
          tx > 0 ? ' across $tx transaction${tx == 1 ? '' : 's'}' : '';
      return "Today's revenue: YER ${_fmt(ctx.todayRevenue)}$txLabel.\n"
          "Profit: YER ${_fmt(ctx.todayProfit)}.";
    }

    // ── Low stock / restock / order ──────────────────────────────────────────
    if (q.contains('stock') ||
        q.contains('order') ||
        q.contains('restock') ||
        q.contains('low')) {
      if (ctx.lowStockProducts.isEmpty) {
        return '✅ All products are well-stocked. No restocking needed right now.';
      }
      final list = ctx.lowStockProducts
          .take(5)
          .map((p) => '• ${p.name} (${p.quantity} left)')
          .join('\n');
      final more = ctx.lowStockCount > 5 ? '\n…and ${ctx.lowStockCount - 5} more.' : '';
      return '⚠️ ${ctx.lowStockCount} product${ctx.lowStockCount == 1 ? '' : 's'} '
          'need${ctx.lowStockCount == 1 ? 's' : ''} restocking:\n$list$more\n\n'
          'Open Inventory for full details.';
    }

    // ── Debt ─────────────────────────────────────────────────────────────────
    if (q.contains('debt') || q.contains('owe') || q.contains('credit')) {
      if (ctx.unpaidDebtCount == 0) {
        return '✅ No outstanding debts. All accounts are clear.';
      }
      return 'Outstanding debt: YER ${_fmt(ctx.totalOutstandingDebt)} '
          'across ${ctx.unpaidDebtCount} customer${ctx.unpaidDebtCount == 1 ? '' : 's'}.\n\n'
          'Open Debts to see full details.';
    }

    // ── Customers ────────────────────────────────────────────────────────────
    if (q.contains('customer')) {
      return 'You have ${ctx.customerCount} registered '
          'customer${ctx.customerCount == 1 ? '' : 's'} in the database.';
    }

    // ── Inventory / products ─────────────────────────────────────────────────
    if (q.contains('inventory') || q.contains('product')) {
      final stockNote = ctx.lowStockCount > 0
          ? '⚠️ ${ctx.lowStockCount} of them need restocking.'
          : '✅ All products are well-stocked.';
      return 'Your inventory has ${ctx.inventoryCount} '
          'product${ctx.inventoryCount == 1 ? '' : 's'}.\n$stockNote';
    }

    // ── Slow sellers ─────────────────────────────────────────────────────────
    if (q.contains('slow') || q.contains('not selling')) {
      return 'For detailed slow-seller analysis, open the Analytics section — '
          'it shows product performance broken down by period.';
    }

    // ── Best sellers / top ───────────────────────────────────────────────────
    if (q.contains('best') || q.contains('top sell')) {
      return 'Open the Analytics section to see your top-selling products '
          'by day, week, or month.';
    }

    // ── Default help ─────────────────────────────────────────────────────────
    return 'I can help you with:\n'
        '• Today\'s profit and revenue\n'
        '• Low stock and restock alerts\n'
        '• Outstanding debt overview\n'
        '• Customer and inventory counts\n\n'
        'Try asking: "How much profit did I make today?" or '
        '"What products need restocking?"';
  }

  /// Formats a number with thousands separators. e.g. 18500 → "18,500"
  String _fmt(double v) {
    return v
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  }
}
