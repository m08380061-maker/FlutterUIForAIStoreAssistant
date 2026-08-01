import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utilities/app_date_utils.dart';
import '../../../shared/models/sale_model.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/sale_repository.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/stat_card.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  int _navIndex = 0;

  List<Widget> _tabs(BuildContext context) {
    final tr = context.tr;
    return [
      const _DashboardTab(),
      _PlaceholderTab(label: tr.inventory, icon: Icons.inventory_2_rounded, route: '/inventory'),
      _PlaceholderTab(label: tr.sales, icon: Icons.receipt_long_rounded, route: '/sales'),
      _PlaceholderTab(label: tr.analytics, icon: Icons.bar_chart_rounded, route: '/analytics'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _tabs(context)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 0) { setState(() => _navIndex = 0); return; }
          // Navigate to full screens for other tabs
          switch (i) {
            case 1: context.push('/inventory');
            case 2: context.push('/sales');
            case 3: context.push('/analytics');
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard_rounded), label: tr.home),
          BottomNavigationBarItem(icon: const Icon(Icons.inventory_2_rounded), label: tr.inventory),
          BottomNavigationBarItem(icon: const Icon(Icons.receipt_long_rounded), label: tr.sales),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_rounded), label: tr.analytics),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final ProductRepository _productRepository = ProductRepository();
  final SaleRepository _saleRepository = SaleRepository();
  int _inventoryCount = 0;
  int _lowStockCount = 0;
  double _todayRevenue = 0;
  double _todayProfit = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    try {
      final inventoryCount = await _productRepository.getInventoryCount();
      final lowStockCount = await _productRepository.getLowStockCount();
      final todayRevenue = await _saleRepository.getTodayRevenue();
      final todayProfit = await _saleRepository.getTodayProfit();
      if (!mounted) return;
      setState(() {
        _inventoryCount = inventoryCount;
        _lowStockCount = lowStockCount;
        _todayRevenue = todayRevenue;
        _todayProfit = todayProfit;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final user = AuthService.instance.currentUser;
    final textTheme = Theme.of(context).textTheme;
    final greeting = _greeting(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                    Text(
                      user?.fullName ?? tr.merchantFallback,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Date
                Text(
                  AppDateUtils.formatDate(DateTime.now()),
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 16),

                // Stats grid
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(
                            label: tr.todaySales,
                            value: tr.formatCurrency(_todayRevenue),
                            icon: Icons.trending_up_rounded,
                            color: AppColors.primary,
                            change: null,
                          ),
                          StatCard(
                            label: tr.todayProfit,
                            value: tr.formatCurrency(_todayProfit),
                            icon: Icons.attach_money_rounded,
                            color: AppColors.accent,
                            change: null,
                          ),
                          StatCard(
                            label: tr.inventory,
                            value: '$_inventoryCount ${tr.items}',
                            icon: Icons.inventory_2_rounded,
                            color: const Color(0xFF7C3AED),
                            change: null,
                          ),
                          StatCard(
                            label: tr.lowStock,
                            value: '$_lowStockCount ${tr.products}',
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.warning,
                            change: null,
                            isPositiveChange: false,
                          ),
                        ],
                      ),
                const SizedBox(height: 20),

                // Quick actions
                Text(tr.quickActions, style: textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuickAction(
                      label: tr.newSale,
                      icon: Icons.add_shopping_cart_rounded,
                      color: AppColors.primary,
                      onTap: () => context.push('/sales'),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      label: tr.quickScanCashier,
                      icon: Icons.document_scanner_rounded,
                      color: const Color(0xFF059669),
                      onTap: () => context.push('/scanner/live'),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      label: tr.aiAssistant,
                      icon: Icons.psychology_rounded,
                      color: AppColors.accentOrange,
                      onTap: () => context.push('/ai-assistant'),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      label: tr.addDebt,
                      icon: Icons.person_add_rounded,
                      color: AppColors.error,
                      onTap: () => context.push('/debts'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // AI Recommendations
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr.aiRecommendations, style: textTheme.titleMedium),
                    TextButton(
                      onPressed: () => context.push('/ai-assistant'),
                      child: Text(tr.viewAll),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _AiRecommendationCard(
                  message: tr.aiRec1,
                ),
                const SizedBox(height: 8),
                _AiRecommendationCard(
                  message: tr.aiRec2,
                ),
                const SizedBox(height: 20),

                // Recent transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr.recentTransactions, style: textTheme.titleMedium),
                    TextButton(onPressed: () => context.push('/sales'), child: Text(tr.viewAll)),
                  ],
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<SaleModel>>(
                  stream: _saleRepository.watchRecentSales(limit: 5),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          tr.unableLoadSales,
                          style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final sales = snapshot.data!;
                    if (sales.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            tr.noSalesToday,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: sales
                          .map((sale) => _TransactionTile(sale: sale))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ai-assistant'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.psychology_rounded, color: Colors.white),
        label: Text(tr.aiAssistant, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _greeting(BuildContext context) {
    final h = DateTime.now().hour;
    if (h < 12) return context.tr.goodMorning;
    if (h < 17) return context.tr.goodAfternoon;
    return context.tr.goodEvening;
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label, required this.icon, required this.route});
  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(label)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push(route),
                child: Text('${context.tr.open} $label'),
              ),
            ],
          ),
        ),
      );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiRecommendationCard extends StatelessWidget {
  const _AiRecommendationCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.psychology_rounded, color: AppColors.accentOrange, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.sale});
  final SaleModel sale;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final textTheme = Theme.of(context).textTheme;
    final itemCount = sale.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final timeLabel = AppDateUtils.relativeTime(sale.createdAt.toLocal());
    final amountLabel = '+${tr.formatCurrency(sale.total)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemCount ${tr.items}',
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(timeLabel, style: textTheme.bodySmall),
                ],
              ),
            ),
            Text(
              amountLabel,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
