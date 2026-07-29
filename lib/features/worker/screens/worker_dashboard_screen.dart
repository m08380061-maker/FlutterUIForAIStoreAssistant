import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/app_card.dart';

/// Worker mode — limited interface.
/// Workers can: scan products, register sales, update stock.
/// Workers cannot: view profits, analytics, private merchant data.
class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final user = AuthService.instance.currentUser;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.workerPanel),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService.instance.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Worker greeting
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(
                      user?.initials ?? 'W',
                      style: textTheme.titleMedium?.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? tr.workerFallback, style: textTheme.titleMedium),
                        Text(
                          '${tr.workerFallback} • ${user?.storeName ?? tr.workerStoreFallback}',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      tr.active,
                      style: textTheme.labelSmall?.copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(tr.quickActions, style: textTheme.titleMedium),
            const SizedBox(height: 12),

            // Action cards
            _WorkerActionCard(
              title: tr.registerSale,
              description: tr.registerSaleDesc,
              icon: Icons.add_shopping_cart_rounded,
              color: AppColors.primary,
              onTap: () => context.push('/sales'),
            ),
            const SizedBox(height: 12),
            _WorkerActionCard(
              title: tr.scanProduct,
              description: tr.scanProductDesc,
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFF7C3AED),
              onTap: () => context.push('/scanner'),
            ),
            const SizedBox(height: 12),
            _WorkerActionCard(
              title: tr.updateStock,
              description: tr.updateStockDesc,
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFF059669),
              onTap: () => context.push('/inventory'),
            ),
            const SizedBox(height: 24),

            // Today's summary (no financial data)
            Text(tr.todaysActivity, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      children: [
                        Text('47', style: textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(tr.salesProcessed, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    child: Column(
                      children: [
                        Text('12', style: textTheme.headlineMedium?.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(tr.itemsScanned, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Restricted access notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr.workerNotice,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerActionCard extends StatelessWidget {
  const _WorkerActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).colorScheme.outline),
        ],
      ),
    );
  }
}
