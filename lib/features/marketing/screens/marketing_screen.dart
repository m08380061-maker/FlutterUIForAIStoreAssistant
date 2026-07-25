import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/promotion_model.dart';
import '../../../shared/repositories/promotion_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_overlay.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketing'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Promotions'),
            Tab(text: 'Customer Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PromotionsTab(),
          _MessagesTab(),
        ],
      ),
    );
  }
}

class _PromotionsTab extends StatefulWidget {
  const _PromotionsTab();

  @override
  State<_PromotionsTab> createState() => _PromotionsTabState();
}

class _PromotionsTabState extends State<_PromotionsTab> {
  final _repo = PromotionRepository();
  List<PromotionModel> _promotions = [];
  StreamSubscription<List<PromotionModel>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _repo.watchPromotions().listen((list) {
      if (mounted) setState(() => _promotions = list);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _showCreatePromotion() {
    final titleCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Promotion', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Promotion Title', hintText: 'e.g. Weekend Special')),
            const SizedBox(height: 12),
            TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount %', hintText: '10')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isNotEmpty) {
                  final discount = discountCtrl.text.trim().isEmpty
                      ? '0%'
                      : '${discountCtrl.text.trim()}%';
                  await _repo.createPromotion(
                    title: titleCtrl.text.trim(),
                    discount: discount,
                    expiresAt: DateTime.now().add(const Duration(days: 7)),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('Create Promotion'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePromotion(String id) async {
    await _repo.deletePromotion(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _promotions.isEmpty
          ? EmptyState(
              icon: Icons.local_offer_outlined,
              title: 'No promotions yet',
              subtitle: 'Create your first promotion to attract more customers.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingMD),
              itemCount: _promotions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final promo = _promotions[i];
                return Dismissible(
                  key: ValueKey(promo.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) => _deletePromotion(promo.id),
                  child: _PromotionCard(
                    promo: promo,
                    onToggle: () => _repo.togglePromotion(promo.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePromotion,
        backgroundColor: AppColors.accentOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Create Promotion', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promo, required this.onToggle});
  final PromotionModel promo;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Text(
              promo.discount,
              style: textTheme.titleMedium?.copyWith(color: AppColors.accentOrange, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.title, style: textTheme.titleSmall),
                Text(
                  'Expires ${_fmtDate(promo.expiresAt)}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(value: promo.isActive, onChanged: (_) => onToggle(), activeColor: AppColors.primary),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _MessagesTab extends StatefulWidget {
  const _MessagesTab();

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _sending = false; _msgCtrl.clear(); });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sent to all customers!'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Broadcast Message', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send a message to all your customers', style: textTheme.bodySmall),
                const SizedBox(height: 12),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Type your message here... (e.g. Weekend sale: 20% off all beverages!)'),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: _sending ? 'Sending...' : 'Send to All Customers',
                  onPressed: _sending ? null : _sendMessage,
                  isLoading: _sending,
                  leading: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Message Templates', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._templates.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  onTap: () => setState(() => _msgCtrl.text = t['body']!),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['title']!, style: textTheme.titleSmall),
                            const SizedBox(height: 2),
                            Text(t['body']!, style: textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

const _templates = [
  {
    'title': 'Weekend Sale',
    'body': '🎉 Weekend Special! Get 15% off on all beverages and snacks this Friday and Saturday. Visit us now!',
  },
  {
    'title': 'New Stock Arrival',
    'body': '📦 New stock just arrived! Fresh products, great prices. Come visit your favorite store today.',
  },
  {
    'title': 'Loyalty Appreciation',
    'body': '❤️ Thank you for being a loyal customer! Enjoy an exclusive 10% discount on your next purchase.',
  },
];
