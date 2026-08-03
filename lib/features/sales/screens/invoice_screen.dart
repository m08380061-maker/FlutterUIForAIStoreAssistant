import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/repositories/sale_repository.dart';
import '../../../shared/widgets/app_card.dart';

// ── Data class ────────────────────────────────────────────────────────────────

class _InvoiceItem {
  final String id;
  final String name;
  final double unitPrice;
  int quantity;

  _InvoiceItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// Instant invoice screen shown after live scanning.
///
/// Accepts [initialItems] as a list of maps with keys:
///   id, name, unitPrice, quantity
///
/// Four primary actions: Complete Sale, Edit, Cancel, Electronic Payment.
class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, required this.initialItems});
  final List<Map<String, dynamic>> initialItems;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final SaleRepository _saleRepo = SaleRepository();
  late final List<_InvoiceItem> _items;
  bool _editMode = false;
  bool _isSaving = false;

  double get _total => _items.fold(0.0, (s, i) => s + i.lineTotal);
  int get _totalItems => _items.fold(0, (s, i) => s + i.quantity);

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems
        .map((m) => _InvoiceItem(
              id: m['id'] as String,
              name: m['name'] as String,
              unitPrice: (m['unitPrice'] as num).toDouble(),
              quantity: (m['quantity'] as num).toInt(),
            ))
        .toList();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _completeSale({String paymentMethod = 'cash'}) async {
    if (_items.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await _saleRepo.createSale(
        items: _items
            .map((i) => ProductModel(
                  id: i.id,
                  name: i.name,
                  category: 'Sale',
                  purchasePrice: 0,
                  sellingPrice: i.unitPrice,
                  quantity: i.quantity,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
            .toList(),
        discount: 0,
        workerId: 'local-worker',
        paymentMethod: paymentMethod,
      );
      if (!mounted) return;
      _showSuccessAndNavigate();
    } on RepositoryException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessAndNavigate() {
    final tr = context.tr;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white),
        const SizedBox(width: 10),
        Text(tr.saleConfirmedMsg),
      ]),
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 2),
    ));
    context.go('/ai-assistant');
  }

  void _showElectronicPayment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ElectronicPaymentSheet(
        total: _total,
        tr: ctx.tr,
        onConfirm: () {
          Navigator.pop(ctx);
          _completeSale(paymentMethod: 'electronic');
        },
      ),
    );
  }

  void _cancel() => context.go('/scanner/live');

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.instantInvoice),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancel,
        ),
        actions: [
          TextButton.icon(
            onPressed: _cancel,
            icon: const Icon(Icons.document_scanner_rounded, size: 18),
            label: Text(tr.scanMore),
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(tr.invoiceEmpty,
                      style: textTheme.bodyLarge),
                ],
              ),
            )
          : Column(
              children: [
                // ── Items list ─────────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => _ItemTile(
                      item: _items[i],
                      editMode: _editMode,
                      onIncrement: () =>
                          setState(() => _items[i].quantity++),
                      onDecrement: () {
                        if (_items[i].quantity > 1) {
                          setState(() => _items[i].quantity--);
                        }
                      },
                      onDelete: () =>
                          setState(() => _items.removeAt(i)),
                      tr: tr,
                    ),
                  ),
                ),

                // ── Bottom panel ───────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        // Total row
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_totalItems ${tr.items}',
                              style: textTheme.bodyMedium,
                            ),
                            Text(
                              tr.formatCurrency(_total),
                              style: textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (_isSaving)
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          )
                        else ...[
                          // Primary: Complete Sale
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _completeSale,
                              icon: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white),
                              label: Text(tr.completeSale),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusMedium),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Secondary row
                          Row(
                            children: [
                              Expanded(
                                child: _SecondaryBtn(
                                  icon: _editMode
                                      ? Icons.lock_rounded
                                      : Icons.edit_rounded,
                                  label: _editMode
                                      ? tr.done
                                      : tr.edit,
                                  color: AppColors.primary,
                                  onTap: () => setState(
                                      () => _editMode = !_editMode),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SecondaryBtn(
                                  icon: Icons.close_rounded,
                                  label: tr.cancel,
                                  color: AppColors.error,
                                  onTap: _cancel,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _SecondaryBtn(
                                  icon: Icons.payment_rounded,
                                  label: tr.electronicPayment,
                                  color: const Color(0xFF7C3AED),
                                  onTap: _showElectronicPayment,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Item tile ─────────────────────────────────────────────────────────────────

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.editMode,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    required this.tr,
  });
  final _InvoiceItem item;
  final bool editMode;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  '${tr.formatCurrency(item.unitPrice)} ${tr.each}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (editMode) ...[
            _QtyRow(
              qty: item.quantity,
              onInc: onIncrement,
              onDec: onDecrement,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 22),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '×${item.quantity}',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              tr.formatCurrency(item.lineTotal),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QtyRow extends StatelessWidget {
  const _QtyRow(
      {required this.qty, required this.onInc, required this.onDec});
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(icon: Icons.remove_rounded, onTap: onDec),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$qty',
              style: Theme.of(context).textTheme.titleSmall),
        ),
        _IconBtn(icon: Icons.add_rounded, onTap: onInc),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  const _SecondaryBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }
}

// ── Electronic Payment sheet ──────────────────────────────────────────────────

class _ElectronicPaymentSheet extends StatelessWidget {
  const _ElectronicPaymentSheet({
    required this.total,
    required this.tr,
    required this.onConfirm,
  });
  final double total;
  final AppTranslations tr;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title + amount
          Text(tr.electronicPayment,
              style: textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            tr.formatCurrency(total),
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),

          // QR code placeholder
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2_rounded,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.6)),
                const SizedBox(height: 8),
                Text(
                  'QR Code',
                  style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primary.withOpacity(0.6)),
                ),
                Text(
                  '— ${tr.paymentQRHint} —',
                  style: textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check_circle_rounded,
                  color: Colors.white),
              label: Text(tr.confirmPayment),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
