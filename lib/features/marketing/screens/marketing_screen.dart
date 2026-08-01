import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
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
    final tr = context.tr;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.marketing),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: tr.promotions),
            Tab(text: tr.customerMessages),
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
  final List<_Promotion> _promotions = List.from(_demoPromotions);

  void _showCreatePromotion() {
    final tr = context.tr;
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
            Text(tr.createPromotion, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: tr.promotionTitle, hintText: tr.promotionTitleHint)),
            const SizedBox(height: 12),
            TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr.discountPercent, hintText: '10')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _promotions.insert(0, _Promotion(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleCtrl.text.trim(),
                      discount: '${discountCtrl.text.trim()}%',
                      isActive: true,
                      expiresAt: DateTime.now().add(const Duration(days: 7)),
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: Text(tr.createPromotion),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Scaffold(
      body: _promotions.isEmpty
          ? EmptyState(
              icon: Icons.local_offer_outlined,
              title: tr.noPromotionsYet,
              subtitle: tr.createFirstPromotion,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingMD),
              itemCount: _promotions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _PromotionCard(
                promo: _promotions[i],
                onToggle: () => setState(() => _promotions[i] = _promotions[i].toggle()),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePromotion,
        backgroundColor: AppColors.accentOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(tr.createPromotion, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promo, required this.onToggle});
  final _Promotion promo;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.12),
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
                  '${tr.expires} ${_fmtDate(promo.expiresAt)}',
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

  List<Map<String, String>> _templates(BuildContext context) {
    final tr = context.tr;
    return [
      {'title': tr.weekendSaleTitle, 'body': tr.weekendSaleBody},
      {'title': tr.newStockTitle, 'body': tr.newStockBody},
      {'title': tr.loyaltyTitle, 'body': tr.loyaltyBody},
    ];
  }

  Future<void> _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _sending = false; _msgCtrl.clear(); });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr.messageSent), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final textTheme = Theme.of(context).textTheme;
    final templates = _templates(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.broadcastMessage, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr.broadcastDesc, style: textTheme.bodySmall),
                const SizedBox(height: 12),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(hintText: tr.broadcastHint),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: _sending ? tr.sending : tr.sendToAllCustomers,
                  onPressed: _sending ? null : _sendMessage,
                  isLoading: _sending,
                  leading: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(tr.messageTemplates, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          ...templates.map((t) => Padding(
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

class _Promotion {
  final String id;
  final String title;
  final String discount;
  final bool isActive;
  final DateTime expiresAt;

  const _Promotion({required this.id, required this.title, required this.discount, required this.isActive, required this.expiresAt});
  _Promotion toggle() => _Promotion(id: id, title: title, discount: discount, isActive: !isActive, expiresAt: expiresAt);
}

final _demoPromotions = [
  _Promotion(id: '1', title: 'Weekend Special', discount: '15%', isActive: true, expiresAt: DateTime.now().add(const Duration(days: 2))),
  _Promotion(id: '2', title: 'Bulk Buy Deal', discount: '10%', isActive: true, expiresAt: DateTime.now().add(const Duration(days: 14))),
  _Promotion(id: '3', title: 'Ramadan Offer', discount: '20%', isActive: false, expiresAt: DateTime.now().subtract(const Duration(days: 30))),
];
