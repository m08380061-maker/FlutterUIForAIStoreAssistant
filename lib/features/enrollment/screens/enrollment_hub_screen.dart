import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/product_draft_service.dart';
import '../../../shared/widgets/app_card.dart';

class EnrollmentHubScreen extends StatefulWidget {
  const EnrollmentHubScreen({super.key});

  @override
  State<EnrollmentHubScreen> createState() => _EnrollmentHubScreenState();
}

class _EnrollmentHubScreenState extends State<EnrollmentHubScreen> {
  late final Stream<List<DraftProduct>> _draftsStream;

  @override
  void initState() {
    super.initState();
    _draftsStream = _draftsStreamBuilder();
  }

  Stream<List<DraftProduct>> _draftsStreamBuilder() async* {
    while (true) {
      yield await ProductDraftService.instance.getPendingDrafts();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.addProduct),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/inventory'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.enrollProductTitle,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              tr.enrollProductSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),

            // ── Four entry paths ──────────────────────────────────
            _EntryCard(
              icon: Icons.qr_code_scanner_rounded,
              title: tr.enrollByBarcode,
              subtitle: tr.enrollByBarcodeDesc,
              color: AppColors.primary,
              onTap: () => context.push('/enrollment/barcode'),
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.camera_alt_rounded,
              title: tr.enrollByPhoto,
              subtitle: tr.enrollByPhotoDesc,
              color: const Color(0xFF059669),
              onTap: () => context.push('/enrollment/photo'),
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.receipt_long_rounded,
              title: tr.enrollByInvoice,
              subtitle: tr.enrollByInvoiceDesc,
              color: AppColors.accentOrange,
              onTap: () => context.push('/enrollment/invoice'),
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.edit_note_rounded,
              title: tr.enrollManual,
              subtitle: tr.enrollManualDesc,
              color: const Color(0xFF7C3AED),
              onTap: () => context.push('/enrollment/manual'),
            ),
            const SizedBox(height: 32),

            // ── Pending drafts ─────────────────────────────────────
            StreamBuilder<List<DraftProduct>>(
              stream: _draftsStream,
              builder: (context, snapshot) {
                final drafts = snapshot.data ?? [];
                if (drafts.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tr.pendingDrafts,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Text(
                            '${drafts.length}',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...drafts.map((draft) => _DraftCard(
                          draft: draft,
                          onTap: () => context.push('/enrollment/draft/${draft.id}'),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                )),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16,
              color: Theme.of(context).colorScheme.outline),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.draft, required this.onTap});
  final DraftProduct draft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: const Icon(Icons.drafts_rounded, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(draft.name, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '${_sourceLabel(draft.source, tr)} · ${draft.completionPercent}%',
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: draft.completionPercent / 100,
                  color: AppColors.primary,
                  strokeWidth: 3,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                ),
                Center(
                  child: Text(
                    '${draft.completionPercent}%',
                    style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sourceLabel(DraftSource source, AppTranslations tr) {
    switch (source) {
      case DraftSource.barcode:
        return tr.enrollByBarcode;
      case DraftSource.photo:
        return tr.enrollByPhoto;
      case DraftSource.invoice:
        return tr.enrollByInvoice;
      case DraftSource.manual:
        return tr.enrollManual;
    }
  }
}
