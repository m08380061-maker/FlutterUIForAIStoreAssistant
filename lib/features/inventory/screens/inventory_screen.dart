import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();

  /// Repository used for all CRUD operations.
  final _repository = ProductRepository();

  /// Reactive stream — emits a fresh list whenever the database changes.
  late final Stream<List<ProductModel>> _productsStream;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _productsStream = _repository.watchAllProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final tr = context.tr;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.deleteProduct),
        content: Text('${tr.deleteProduct} ${product.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr.delete)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteProduct(product.id);
      // Stream auto-refreshes — just show confirmation.
      _showMessage(tr.productRemoved);
    } on RepositoryException catch (e) {
      _showMessage(e.message, isError: true);
    }
  }

  void _showEditProduct(ProductModel product) {
    final tr = context.tr;
    final nameCtrl = TextEditingController(text: product.name);
    final categoryCtrl = TextEditingController(text: product.category);
    final purchasePriceCtrl =
        TextEditingController(text: product.purchasePrice.toString());
    final sellingPriceCtrl =
        TextEditingController(text: product.sellingPrice.toString());
    final quantityCtrl =
        TextEditingController(text: product.quantity.toString());
    final barcodeCtrl = TextEditingController(text: product.barcode ?? '');
    final descriptionCtrl =
        TextEditingController(text: product.description ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr.editProduct,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                CustomTextField(
                    label: tr.productName,
                    controller: nameCtrl,
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? tr.required : null),
                const SizedBox(height: 12),
                CustomTextField(
                    label: tr.category,
                    controller: categoryCtrl,
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? tr.required : null),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: CustomTextField(
                          label: tr.purchasePrice,
                          controller: purchasePriceCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              (double.tryParse(v ?? '') ?? -1) < 0
                                  ? tr.mustBeNumber
                                  : null)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: CustomTextField(
                          label: tr.sellingPrice,
                          controller: sellingPriceCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              (double.tryParse(v ?? '') ?? -1) < 0
                                  ? tr.mustBeNumber
                                  : null)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: CustomTextField(
                          label: tr.quantity,
                          controller: quantityCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              (int.tryParse(v ?? '') ?? -1) < 0
                                  ? tr.mustBeNumber
                                  : null)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: CustomTextField(
                          label: tr.barcodeOptional,
                          controller: barcodeCtrl)),
                ]),
                const SizedBox(height: 12),
                CustomTextField(
                    label: tr.descriptionOptional,
                    controller: descriptionCtrl,
                    maxLines: 3),
                const SizedBox(height: 20),
                CustomButton(
                    label: tr.saveChanges,
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      try {
                        await _repository.updateProduct(
                          id: product.id,
                          name: nameCtrl.text,
                          category: categoryCtrl.text,
                          purchasePrice: double.parse(purchasePriceCtrl.text),
                          sellingPrice: double.parse(sellingPriceCtrl.text),
                          quantity: int.parse(quantityCtrl.text),
                          barcode: barcodeCtrl.text.trim().isEmpty
                              ? null
                              : barcodeCtrl.text.trim(),
                          description: descriptionCtrl.text.trim().isEmpty
                              ? null
                              : descriptionCtrl.text.trim(),
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        // Stream auto-refreshes — just show confirmation.
                        _showMessage(tr.productUpdated);
                      } on RepositoryException catch (e) {
                        if (!mounted) return;
                        _showMessage(e.message, isError: true);
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.inventory),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: tr.all),
            Tab(text: tr.lowStock),
            Tab(text: tr.outOfStock),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: tr.searchProducts,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${tr.errorLoadingProducts}: ${snapshot.error}',
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!;

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _InventoryList(
                        filter: 'all',
                        query: _query,
                        products: products,
                        onEdit: _showEditProduct,
                        onDelete: _deleteProduct),
                    _InventoryList(
                        filter: 'low',
                        query: _query,
                        products: products,
                        onEdit: _showEditProduct,
                        onDelete: _deleteProduct),
                    _InventoryList(
                        filter: 'out',
                        query: _query,
                        products: products,
                        onEdit: _showEditProduct,
                        onDelete: _deleteProduct),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scanner'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(tr.addProduct, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _InventoryList extends StatelessWidget {
  const _InventoryList(
      {required this.filter,
      required this.query,
      required this.products,
      required this.onEdit,
      required this.onDelete});
  final String filter;
  final String query;
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onEdit;
  final ValueChanged<ProductModel> onDelete;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final filtered = products.where((product) {
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase()) ||
          (product.barcode ?? '').toLowerCase().contains(query.toLowerCase());
      final matchesFilter = filter == 'all' ||
          (filter == 'low' && product.isLowStock) ||
          (filter == 'out' && product.isOutOfStock);
      return matchesQuery && matchesFilter;
    }).toList();

    if (filtered.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: tr.noProductsFound,
        subtitle: filter == 'low'
            ? tr.noLowStock
            : filter == 'out'
                ? tr.noOutOfStock
                : tr.addFirstProduct,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) =>
          _ProductRow(product: filtered[i], onEdit: onEdit, onDelete: onDelete),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow(
      {required this.product, required this.onEdit, required this.onDelete});
  final ProductModel product;
  final ValueChanged<ProductModel> onEdit;
  final ValueChanged<ProductModel> onDelete;

  Color get _statusColor {
    if (product.isOutOfStock) return AppColors.error;
    if (product.isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: AppConstants.thumbnailSize,
            height: AppConstants.thumbnailSize,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(product.category, style: textTheme.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _InfoBadge(
                        label: '${tr.qty}: ${product.quantity}',
                        color: _statusColor),
                    const SizedBox(width: 6),
                    _InfoBadge(label: product.stockStatus, color: _statusColor),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tr.formatCurrency(product.sellingPrice),
                style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconBtn(
                      icon: Icons.edit_outlined,
                      onTap: () => onEdit(product)),
                  const SizedBox(width: 4),
                  _IconBtn(
                      icon: Icons.delete_outline_rounded,
                      onTap: () => onDelete(product),
                      color: AppColors.error),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color ?? AppColors.primary),
      ),
    );
  }
}
