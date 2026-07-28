import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/models/sale_model.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/repositories/sale_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_overlay.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ProductRepository _productRepository = ProductRepository();
  final SaleRepository _saleRepository = SaleRepository();
  final List<_CartItem> _cart = [];
  final _searchCtrl = TextEditingController();
  List<ProductModel> _products = [];
  String _query = '';
  double _discount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  late final Stream<List<SaleModel>> _salesStream;
  late MobileScannerController _scanController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scanController = MobileScannerController();
    _loadProducts();
    _salesStream = _saleRepository.watchRecentSales();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final products = await _productRepository.getAllProducts(query: _query);
      setState(() => _products = products);
    } on RepositoryException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _subtotal => _cart.fold(0, (s, i) => s + i.totalPrice);
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);

  void _addToCart(ProductModel product) {
    final idx = _cart.indexWhere((c) => c.id == product.id);
    if (idx >= 0) {
      setState(() => _cart[idx] = _cart[idx].increment());
    } else {
      setState(() => _cart.add(_CartItem(id: product.id, name: product.name, unitPrice: product.sellingPrice, quantity: 1)));
    }
  }

  void _removeFromCart(String id) {
    setState(() => _cart.removeWhere((c) => c.id == id));
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final barcode = barcodes.first.rawValue;
    if (barcode == null || barcode.isEmpty) return;
    _scanController.stop();
    _lookupAndAddByBarcode(barcode);
  }

  Future<void> _lookupAndAddByBarcode(String barcode) async {
    try {
      final products = await _productRepository.getAllProducts();
      final match = products.where((p) => p.barcode == barcode).firstOrNull;
      if (match != null) {
        _addToCart(match);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added: ${match.name} — YER ${match.sellingPrice.toStringAsFixed(0)}'), backgroundColor: AppColors.success, duration: const Duration(seconds: 1)),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No product found for barcode: $barcode'), backgroundColor: AppColors.warning),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan error: $e'), backgroundColor: AppColors.error));
    }
  }

  void _showBarcodeScanner() {
    _scanController = MobileScannerController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Scan Barcode', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () { _scanController.stop(); Navigator.pop(ctx); }),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                controller: _scanController,
                onDetect: (capture) { _onBarcodeDetected(capture); Navigator.pop(ctx); },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ).whenComplete(() => _scanController.stop());
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;
    try {
      await _saleRepository.createSale(
        items: _cart.map((item) => ProductModel(id: item.id, name: item.name, category: 'Sale', purchasePrice: 0, sellingPrice: item.unitPrice, quantity: item.quantity, createdAt: DateTime.now(), updatedAt: DateTime.now())).toList(),
        discount: _discount, workerId: 'local-worker', paymentMethod: 'cash',
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sale Complete! 🎉'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_cart.fold(0, (s, i) => s + i.quantity)} items sold'),
            const SizedBox(height: 8),
            Text('Total: ${_fmtAmount(_total)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Print Receipt')),
            ElevatedButton(
              onPressed: () { setState(() { _cart.clear(); _discount = 0; }); Navigator.pop(ctx); _tabController.animateTo(1); },
              child: const Text('View History'),
            ),
          ],
        ),
      );
    } on RepositoryException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: AppColors.error));
    }
  }

  String _fmtAmount(double v) => 'YER ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'New Sale'), Tab(text: 'History')]),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner_rounded), tooltip: 'Scan to add', onPressed: _showBarcodeScanner),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NewSaleTab(
            products: _products, cart: _cart, query: _query, discount: _discount, isLoading: _isLoading, errorMessage: _errorMessage,
            searchCtrl: _searchCtrl, subtotal: _subtotal, total: _total,
            onQueryChanged: (v) { setState(() => _query = v); _loadProducts(); },
            onAddToCart: _addToCart,
            onIncrement: (i) => setState(() => _cart[i] = _cart[i].increment()),
            onDecrement: (i) { if (_cart[i].quantity <= 1) { _removeFromCart(_cart[i].id); } else { setState(() => _cart[i] = _cart[i].decrement()); } },
            onRemove: (id) => _removeFromCart(id),
            onDiscountChanged: (v) => setState(() => _discount = v),
            onCheckout: _checkout, fmtAmount: _fmtAmount,
          ),
          _SalesHistoryTab(salesStream: _salesStream, fmtAmount: _fmtAmount),
        ],
      ),
    );
  }
}

class _NewSaleTab extends StatelessWidget {
  const _NewSaleTab({required this.products, required this.cart, required this.query, required this.discount, required this.isLoading, required this.errorMessage, required this.searchCtrl, required this.subtotal, required this.total, required this.onQueryChanged, required this.onAddToCart, required this.onIncrement, required this.onDecrement, required this.onRemove, required this.onDiscountChanged, required this.onCheckout, required this.fmtAmount});

  final List<ProductModel> products;
  final List<_CartItem> cart;
  final String query;
  final double discount;
  final bool isLoading;
  final String? errorMessage;
  final TextEditingController searchCtrl;
  final double subtotal;
  final double total;
  final ValueChanged<String> onQueryChanged;
  final void Function(ProductModel) onAddToCart;
  final void Function(int) onIncrement;
  final void Function(int) onDecrement;
  final void Function(String) onRemove;
  final ValueChanged<double> onDiscountChanged;
  final VoidCallback onCheckout;
  final String Function(double) fmtAmount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filtered = products.where((p) => query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase())).toList();
    return LoadingOverlay(
      isLoading: isLoading,
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: TextField(controller: searchCtrl, decoration: const InputDecoration(hintText: 'Search products to add...', prefixIcon: Icon(Icons.search_rounded)), onChanged: onQueryChanged)),
        if (errorMessage != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text(errorMessage!, style: const TextStyle(color: AppColors.error))),
        SizedBox(height: 160, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(AppConstants.paddingMD), itemCount: filtered.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (ctx, i) => _ProductChip(product: filtered[i], onAdd: onAddToCart))),
        Expanded(child: cart.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_cart_outlined, size: 56, color: Theme.of(context).colorScheme.outline), const SizedBox(height: 12), Text('Add products to start a sale', style: textTheme.bodyLarge)])) : ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: cart.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (ctx, i) => _CartTile(item: cart[i], onIncrement: () => onIncrement(i), onDecrement: () => onDecrement(i), onRemove: () => onRemove(cart[i].id)))),
        if (cart.isNotEmpty) Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline))), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Subtotal', style: textTheme.bodyMedium), Text(fmtAmount(subtotal), style: textTheme.bodyMedium)]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Discount', style: textTheme.bodySmall), Text(fmtAmount(discount), style: textTheme.bodySmall?.copyWith(color: AppColors.error))]),
          const Divider(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)), Text(fmtAmount(total), style: textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 12),
          CustomButton(label: 'Checkout — ${fmtAmount(total)}', onPressed: onCheckout),
        ])),
      ]),
    );
  }
}

class _SalesHistoryTab extends StatelessWidget {
  const _SalesHistoryTab({required this.salesStream, required this.fmtAmount});
  final Stream<List<SaleModel>> salesStream;
  final String Function(double) fmtAmount;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SaleModel>>(stream: salesStream, builder: (context, snapshot) {
      if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Error loading sales: ${snapshot.error}', style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center)));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final sales = snapshot.data!;
      if (sales.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_long_outlined, size: 56, color: Theme.of(context).colorScheme.outline), const SizedBox(height: 12), Text('No sales yet', style: Theme.of(context).textTheme.bodyLarge), const SizedBox(height: 4), Text('Complete a sale to see it here.', style: Theme.of(context).textTheme.bodySmall)]));
      return ListView.separated(padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), itemCount: sales.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (ctx, i) => _SaleTile(sale: sales[i], fmtAmount: fmtAmount));
    });
  }
}

class _SaleTile extends StatelessWidget {
  const _SaleTile({required this.sale, required this.fmtAmount});
  final SaleModel sale;
  final String Function(double) fmtAmount;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final itemCount = sale.items.fold<int>(0, (s, i) => s + i.quantity);
    final timeLabel = DateFormat('MMM d, yyyy · HH:mm').format(sale.createdAt.toLocal());
    return AppCard(padding: const EdgeInsets.all(12), child: Row(children: [
      Container(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(AppConstants.radiusSmall)), child: const Icon(Icons.receipt_rounded, color: AppColors.primary, size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$itemCount item${itemCount == 1 ? '' : 's'}', style: textTheme.titleSmall), const SizedBox(height: 2), Text(timeLabel, style: textTheme.bodySmall), if (sale.discount > 0) ...[const SizedBox(height: 2), Text('Discount: ${fmtAmount(sale.discount)}', style: textTheme.bodySmall?.copyWith(color: AppColors.error))]])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(fmtAmount(sale.total), style: textTheme.titleSmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)), const SizedBox(height: 4), _PaymentBadge(method: sale.paymentMethod)]),
    ]));
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.method});
  final String method;
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(AppConstants.radiusFull)), child: Text(method, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary)));
  }
}

class _ProductChip extends StatelessWidget {
  const _ProductChip({required this.product, required this.onAdd});
  final ProductModel product;
  final void Function(ProductModel) onAdd;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(onTap: () => onAdd(product), child: Container(width: 110, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(AppConstants.radiusMedium), border: Border.all(color: Theme.of(context).colorScheme.outline)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 22)),
      const Spacer(),
      Text(product.name, style: textTheme.labelSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 2),
      Text('YER ${product.sellingPrice.toStringAsFixed(0)}', style: textTheme.labelSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
    ])));
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item, required this.onIncrement, required this.onDecrement, required this.onRemove});
  final _CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(padding: const EdgeInsets.all(12), child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, style: textTheme.titleSmall), Text('YER ${item.unitPrice.toStringAsFixed(0)} each', style: textTheme.bodySmall)])),
      Row(children: [_CountBtn(icon: Icons.remove_rounded, onTap: onDecrement), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${item.quantity}', style: textTheme.titleSmall)), _CountBtn(icon: Icons.add_rounded, onTap: onIncrement)]),
      const SizedBox(width: 16),
      Text('YER ${item.totalPrice.toStringAsFixed(0)}', style: textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
      IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: onRemove),
    ]));
  }
}

class _CountBtn extends StatelessWidget {
  const _CountBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 16)));
  }
}

class _CartItem {
  final String id;
  final String name;
  final double unitPrice;
  final int quantity;
  const _CartItem({required this.id, required this.name, required this.unitPrice, required this.quantity});
  double get totalPrice => unitPrice * quantity;
  _CartItem increment() => _CartItem(id: id, name: name, unitPrice: unitPrice, quantity: quantity + 1);
  _CartItem decrement() => _CartItem(id: id, name: name, unitPrice: unitPrice, quantity: quantity - 1);
}
