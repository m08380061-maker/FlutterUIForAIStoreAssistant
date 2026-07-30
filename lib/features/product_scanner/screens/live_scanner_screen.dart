import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public data class shared with SalesScreen via router extra.
// ─────────────────────────────────────────────────────────────────────────────
class ScanCartItem {
  final String id;
  final String name;
  final double unitPrice;
  int quantity;

  ScanCartItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan status
// ─────────────────────────────────────────────────────────────────────────────
enum _ScanStatus { idle, recognizing, found, notFound }

// ─────────────────────────────────────────────────────────────────────────────
// LiveScannerScreen
// ─────────────────────────────────────────────────────────────────────────────
class LiveScannerScreen extends StatefulWidget {
  const LiveScannerScreen({super.key});

  @override
  State<LiveScannerScreen> createState() => _LiveScannerScreenState();
}

class _LiveScannerScreenState extends State<LiveScannerScreen>
    with TickerProviderStateMixin {
  final ProductRepository _repository = ProductRepository();
  List<ProductModel> _products = [];
  final List<ScanCartItem> _cart = [];

  _ScanStatus _status = _ScanStatus.idle;
  ProductModel? _lastScanned;
  DateTime? _lastScanTime;

  Timer? _scanTimer;
  Timer? _statusResetTimer;

  late final AnimationController _frameAnimCtrl;
  late final AnimationController _overlayAnimCtrl;
  late final Animation<double> _frameOpacity;
  late final Animation<double> _overlayAnim;

  bool _isLoading = true;
  final Random _random = Random();

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _frameAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _overlayAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _frameOpacity = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _frameAnimCtrl, curve: Curves.easeInOut),
    );

    _overlayAnim = CurvedAnimation(
      parent: _overlayAnimCtrl,
      curve: Curves.easeOut,
    );

    _loadProducts();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _statusResetTimer?.cancel();
    _frameAnimCtrl.dispose();
    _overlayAnimCtrl.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────────────

  Future<void> _loadProducts() async {
    try {
      final products = await _repository.getAllProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
      _startScanLoop();
    } on RepositoryException catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Scanning loop ───────────────────────────────────────────────────────────

  void _startScanLoop() {
    // Every 2.5 s the scanner "sees" something and tries to recognise it.
    // TODO: Replace this timer with a real MobileScanner frame callback when
    //       running on a physical device with `mobile_scanner` integrated.
    _scanTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (_status == _ScanStatus.idle && mounted) {
        _triggerRecognition();
      }
    });
  }

  void _triggerRecognition() {
    if (_products.isEmpty) {
      // No products in DB yet — show not-found instead of crashing.
      setState(() => _status = _ScanStatus.notFound);
      _statusResetTimer?.cancel();
      _statusResetTimer = Timer(const Duration(milliseconds: 1800), () {
        if (mounted) setState(() => _status = _ScanStatus.idle);
      });
      return;
    }

    setState(() => _status = _ScanStatus.recognizing);

    // Simulate a recognition delay of 0.7–1.2 s.
    final delayMs = 700 + _random.nextInt(500);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      // 72% success rate when products exist.
      final success = _random.nextDouble() < 0.72;

      if (success) {
        final product = _products[_random.nextInt(_products.length)];

        // Debounce: skip if exactly the same product was detected < 2 s ago.
        final now = DateTime.now();
        if (_lastScanned?.id == product.id &&
            _lastScanTime != null &&
            now.difference(_lastScanTime!) < const Duration(seconds: 2)) {
          setState(() => _status = _ScanStatus.idle);
          return;
        }

        _lastScanned = product;
        _lastScanTime = now;
        _addToCart(product);

        setState(() => _status = _ScanStatus.found);
        _overlayAnimCtrl.forward(from: 0);

        // Auto-hide the overlay after 1.2 s, then resume scanning.
        _statusResetTimer?.cancel();
        _statusResetTimer = Timer(const Duration(milliseconds: 1200), () {
          if (mounted) {
            _overlayAnimCtrl.reverse();
            setState(() => _status = _ScanStatus.idle);
          }
        });
      } else {
        setState(() => _status = _ScanStatus.notFound);
        _statusResetTimer?.cancel();
        _statusResetTimer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _status = _ScanStatus.idle);
        });
      }
    });
  }

  // ── Cart helpers ─────────────────────────────────────────────────────────────

  void _addToCart(ProductModel product) {
    final idx = _cart.indexWhere((c) => c.id == product.id);
    if (idx >= 0) {
      setState(() => _cart[idx].quantity++);
    } else {
      setState(() => _cart.add(ScanCartItem(
            id: product.id,
            name: product.name,
            unitPrice: product.sellingPrice,
          )));
    }
  }

  int get _totalItems => _cart.fold(0, (s, c) => s + c.quantity);

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _goToInvoice() {
    _scanTimer?.cancel();
    _statusResetTimer?.cancel();
    // Navigate to InvoiceScreen with scanned items.
    context.go('/invoice', extra: {
      'cartItems': _cart.map((c) => c.toMap()).toList(),
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Simulated camera feed ──────────────────────────────────────────
          const _CameraBackground(),

          // ── Scan frame (center) ───────────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _frameOpacity,
              builder: (context, _) {
                final color = switch (_status) {
                  _ScanStatus.found => AppColors.success,
                  _ScanStatus.notFound => AppColors.error,
                  _ => AppColors.primary,
                };
                return _ScanFrame(
                  size: 220,
                  color: color.withOpacity(_frameOpacity.value),
                  isRecognizing: _status == _ScanStatus.recognizing,
                );
              },
            ),
          ),

          // ── Top bar (title + status chip) ─────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tr.liveScanTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                    blurRadius: 6, color: Colors.black54),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Scanned-items badge
                        _CartBadge(count: _totalItems),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatusChip(status: _status, tr: tr),
                ],
              ),
            ),
          ),

          // ── Product-found overlay (slides up, auto-hides) ─────────────────
          if (_lastScanned != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 130,
              child: FadeTransition(
                opacity: _overlayAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(_overlayAnim),
                  child: _ProductFoundCard(
                    product: _lastScanned!,
                    quantity: _cart
                        .where((c) => c.id == _lastScanned!.id)
                        .fold(0, (_, c) => c.quantity),
                    tr: tr,
                  ),
                ),
              ),
            ),

          // ── Bottom bar (cart summary + Done button) ────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_cart.isNotEmpty) ...[
                      _CartSummaryBar(cart: _cart, tr: tr),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _cart.isEmpty ? null : _goToInvoice,
                        icon: const Icon(Icons.receipt_long_rounded),
                        label: Text(
                          _cart.isEmpty
                              ? tr.aimCameraAtProduct
                              : '${tr.doneScanning}  ·  $_totalItems ${tr.items}',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _cart.isEmpty
                              ? Colors.white24
                              : AppColors.success,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white24,
                          disabledForegroundColor: Colors.white54,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusMedium),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Loading spinner ────────────────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CameraBackground  –  dark dot-grid to suggest a camera viewfinder
// ─────────────────────────────────────────────────────────────────────────────
class _CameraBackground extends StatelessWidget {
  const _CameraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFF1A1A2E), Color(0xFF000000)],
        ),
      ),
      child: CustomPaint(
        painter: _DotGridPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    const step = 22.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScanFrame  –  corner-bracket viewfinder frame
// ─────────────────────────────────────────────────────────────────────────────
class _ScanFrame extends StatelessWidget {
  const _ScanFrame({
    required this.size,
    required this.color,
    required this.isRecognizing,
  });
  final double size;
  final Color color;
  final bool isRecognizing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Dimmed inner fill
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.05),
            ),
          ),
          // Corner brackets
          ..._corners(color),
          // Scanning line animation
          if (isRecognizing)
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _ScanLine(color: color),
            ),
        ],
      ),
    );
  }

  static List<Widget> _corners(Color color) {
    const len = 28.0;
    const thick = 3.5;
    Widget corner({
      required Alignment alignment,
      required BorderRadius radius,
      required EdgeInsets padding,
    }) =>
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: padding,
              child: SizedBox(
                width: len,
                height: len,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: alignment.y < 0
                          ? BorderSide(color: color, width: thick)
                          : BorderSide.none,
                      bottom: alignment.y > 0
                          ? BorderSide(color: color, width: thick)
                          : BorderSide.none,
                      left: alignment.x < 0
                          ? BorderSide(color: color, width: thick)
                          : BorderSide.none,
                      right: alignment.x > 0
                          ? BorderSide(color: color, width: thick)
                          : BorderSide.none,
                    ),
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          ),
        );

    const p8 = EdgeInsets.all(8);
    return [
      corner(
        alignment: Alignment.topLeft,
        radius: const BorderRadius.only(topLeft: Radius.circular(10)),
        padding: p8,
      ),
      corner(
        alignment: Alignment.topRight,
        radius: const BorderRadius.only(topRight: Radius.circular(10)),
        padding: p8,
      ),
      corner(
        alignment: Alignment.bottomLeft,
        radius: const BorderRadius.only(bottomLeft: Radius.circular(10)),
        padding: p8,
      ),
      corner(
        alignment: Alignment.bottomRight,
        radius: const BorderRadius.only(bottomRight: Radius.circular(10)),
        padding: p8,
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScanLine  –  animated horizontal sweep line inside the frame
// ─────────────────────────────────────────────────────────────────────────────
class _ScanLine extends StatefulWidget {
  const _ScanLine({required this.color});
  final Color color;

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Align(
        alignment: Alignment(0, (_anim.value * 2) - 1),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                widget.color.withOpacity(0.9),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusChip  –  status pill below the title bar
// ─────────────────────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.tr});
  final _ScanStatus status;
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final (text, color, icon) = switch (status) {
      _ScanStatus.idle => (
          tr.aimCameraAtProduct,
          Colors.white.withOpacity(0.85),
          Icons.center_focus_strong_rounded,
        ),
      _ScanStatus.recognizing => (
          tr.recognizing,
          AppColors.warning,
          Icons.radar_rounded,
        ),
      _ScanStatus.found => (
          tr.productFoundLabel,
          AppColors.success,
          Icons.check_circle_rounded,
        ),
      _ScanStatus.notFound => (
          tr.productNotRecognized,
          AppColors.error,
          Icons.highlight_off_rounded,
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(status),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == _ScanStatus.recognizing)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(icon, color: color, size: 16),
              ),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartBadge  –  top-right item counter
// ─────────────────────────────────────────────────────────────────────────────
class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: count == 0
          ? const SizedBox(width: 48)
          : Container(
              key: ValueKey(count),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductFoundCard  –  green popup showing name + price + qty
// ─────────────────────────────────────────────────────────────────────────────
class _ProductFoundCard extends StatelessWidget {
  const _ProductFoundCard({
    required this.product,
    required this.quantity,
    required this.tr,
  });
  final ProductModel product;
  final int quantity;
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tr.formatCurrency(product.sellingPrice),
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
              ],
            ),
          ),
          if (quantity > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                '${tr.timesScanned}$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartSummaryBar  –  compact strip showing scanned items above Done button
// ─────────────────────────────────────────────────────────────────────────────
class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({required this.cart, required this.tr});
  final List<ScanCartItem> cart;
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border:
            Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined,
              color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cart.map((c) => c.quantity > 1 ? '${c.name} ×${c.quantity}' : c.name).join('  ·  '),
              style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            tr.formatCurrency(
                cart.fold(0.0, (s, c) => s + c.totalPrice)),
            style: textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
