import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/repositories/sale_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/stat_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  _Period _period = _Period.week;
  final SaleRepository _saleRepository = SaleRepository();

  int get _periodDays {
    switch (_period) {
      case _Period.week:
        return 7;
      case _Period.month:
        return 30;
      case _Period.year:
        return 365;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr.analytics)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Row(
              children: _Period.values.map((p) {
                final active = _period == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.label(context)),
                    selected: active,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: active ? Colors.white : null),
                    onSelected: (_) => setState(() => _period = p),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // KPI cards — driven by daily revenue/profit stream
            StreamBuilder<List<DailyRevenueProfit>>(
              stream: _saleRepository.watchDailyRevenueProfit(days: _periodDays),
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];
                final totalRevenue = data.fold<double>(0, (s, e) => s + e.revenue);
                final totalProfit = data.fold<double>(0, (s, e) => s + e.profit);
                final totalExpenses = totalRevenue - totalProfit;
                final transactionCount = data.length;

                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      label: context.tr.revenue,
                      value: context.tr.formatCurrency(totalRevenue),
                      icon: Icons.payments_rounded,
                      color: AppColors.primary,
                      change: null,
                    ),
                    StatCard(
                      label: context.tr.profit,
                      value: context.tr.formatCurrency(totalProfit),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.accent,
                      change: null,
                    ),
                    StatCard(
                      label: context.tr.expenses,
                      value: context.tr.formatCurrency(totalExpenses),
                      icon: Icons.receipt_rounded,
                      color: AppColors.error,
                      change: null,
                      isPositiveChange: false,
                    ),
                    StatCard(
                      label: context.tr.transactions,
                      value: '$transactionCount',
                      icon: Icons.swap_horiz_rounded,
                      color: const Color(0xFF7C3AED),
                      change: null,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Revenue chart
            Text(context.tr.revenueVsProfit, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: StreamBuilder<List<DailyRevenueProfit>>(
                  stream: _saleRepository.watchDailyRevenueProfit(days: _periodDays),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? [];
                    final revenueSpots = <FlSpot>[];
                    final profitSpots = <FlSpot>[];
                    for (var i = 0; i < data.length; i++) {
                      revenueSpots.add(FlSpot(i.toDouble(), data[i].revenue));
                      profitSpots.add(FlSpot(i.toDouble(), data[i].profit));
                    }

                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (v) => FlLine(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                final idx = v.toInt();
                                if (idx < 0 || idx >= data.length) {
                                  return const SizedBox.shrink();
                                }
                                final label = _dayLabel(data[idx].date);
                                return Text(label, style: Theme.of(context).textTheme.labelSmall);
                              },
                              reservedSize: 20,
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: revenueSpots,
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withOpacity(0.08),
                            ),
                          ),
                          LineChartBarData(
                            spots: profitSpots,
                            isCurved: true,
                            color: AppColors.accent,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.accent.withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Best sellers
            Text(context.tr.bestSellers, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            StreamBuilder<List<BestSellerEntry>>(
              stream: _saleRepository.watchBestSellers(days: _periodDays),
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(context.tr.noSalesDataPeriod, style: textTheme.bodySmall),
                    ),
                  );
                }
                return Column(
                  children: data.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BestSellerRow(rank: e.key + 1, entry: e.value),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Category breakdown (pie chart)
            Text(context.tr.salesByCategory, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            StreamBuilder<List<CategoryShare>>(
              stream: _saleRepository.watchCategoryBreakdown(days: _periodDays),
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(context.tr.noCategoryData, style: textTheme.bodySmall),
                    ),
                  );
                }
                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: PieChart(
                          PieChartData(
                            sections: data.asMap().entries.map((e) {
                              return PieChartSectionData(
                                value: e.value.percentage,
                                color: AppColors.chartColors[e.key % AppColors.chartColors.length],
                                radius: 50,
                                title: '${e.value.percentage.toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                              );
                            }).toList(),
                            centerSpaceRadius: 20,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: data.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.chartColors[e.key % AppColors.chartColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(child: Text(e.value.category, style: textTheme.bodySmall)),
                                Text('${e.value.percentage.toStringAsFixed(0)}%', style: textTheme.labelSmall),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _fmt(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
  }

  String _dayLabel(DateTime date) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[date.weekday - 1];
  }
}

class _BestSellerRow extends StatelessWidget {
  const _BestSellerRow({required this.rank, required this.entry});
  final int rank;
  final BestSellerEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: rank == 1 ? const Color(0xFFFFD700).withOpacity(0.15)
                  : rank == 2 ? const Color(0xFFC0C0C0).withOpacity(0.15)
                  : rank == 3 ? const Color(0xFFCD7F32).withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(entry.productName, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(context.tr.formatCurrency(entry.revenue), style: textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              Text('${entry.units} ${context.tr.units}', style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtRevenue(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
  }
}

enum _Period {
  week,
  month,
  year;

  String label(BuildContext context) {
    switch (this) {
      case week: return context.tr.thisWeek;
      case month: return context.tr.thisMonth;
      case year: return context.tr.thisYear;
    }
  }
}
