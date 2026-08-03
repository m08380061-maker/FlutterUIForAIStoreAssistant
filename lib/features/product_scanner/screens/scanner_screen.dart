import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/services/offline_product_recognizer.dart';
import '../../../shared/services/product_image_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

/// Product scanner screen.
/// Supports three input modes:
///   1. Barcode scanning (placeholder — requires camera_barcode_scanner integration)
///   2. Product image scanning (placeholder — requires Gemini Vision API)
///   3. Manual entry fallback
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  _ScanMode _mode = _ScanMode.barcode;
  bool _scanned = false;
  bool _isSaving = false;
  XFile? _pickedImage;
  String? _savedImagePath;
  MobileScannerController? _scanController;
  final ProductRepository _repository = ProductRepository();
  final ProductImageService _imageService = ProductImageService();

  // Form controllers for manual / confirmed entry
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();

  @override
  void dispose() {
    _scanController?.dispose();
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _qtyCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  /// Opens the real barcode scanner in a modal and fills the barcode field.
  Future<void> _openBarcodeScanner() async {
    final controller = MobileScannerController();
    setState(() => _scanController = controller);

    String? result;
    try {
      result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.65,
          child: Stack(
            children: [
              MobileScanner(
                controller: controller,
                onDetect: (capture) {
                  final value = capture.barcodes.firstOrNull?.rawValue;
                  if (value != null && value.isNotEmpty) {
                    controller.stop();
                    Navigator.pop(ctx, value);
                  }
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                ),
              ),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      result = null;
    } finally {
      controller.dispose();
    }

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      _barcodeCtrl.text = result;
      try {
        final products = await _repository.getAllProducts();
        final match = OfflineProductRecognizer.findBestMatch(products, result);
        if (match != null) {
          _nameCtrl.text = match.name;
          _categoryCtrl.text = match.category;
          _priceCtrl.text = match.sellingPrice.toString();
          _purchasePriceCtrl.text = match.purchasePrice.toString();
          _qtyCtrl.text = match.quantity.toString();
          _barcodeCtrl.text = match.barcode ?? result;
        }
      } catch (_) {
        // No match — barcode filled, rest entered manually.
      }
      setState(() => _scanned = true);
    }
  }

  /// Opens the device camera to capture a product image and stores it locally.
  Future<void> _openImageCamera() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (!mounted || file == null) return;

      final savedPath = await _imageService.savePickedImage(file);

    final products = await _repository.getAllProducts();
    final match = await OfflineProductRecognizer.matchImageFile(products, savedPath);
      if (!mounted) return;

      setState(() {
        _pickedImage = file;
        _savedImagePath = savedPath;
        _scanned = true;
        if (match != null) {
          _nameCtrl.text = match.name;
          _categoryCtrl.text = match.category;
          _priceCtrl.text = match.sellingPrice.toString();
          _purchasePriceCtrl.text = match.purchasePrice.toString();
          _qtyCtrl.text = match.quantity.toString();
          _barcodeCtrl.text = match.barcode ?? _barcodeCtrl.text;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr.productNotRecognized), backgroundColor: AppColors.error),
      );
    }
  }

  void _handleActivate() {
    if (_mode == _ScanMode.barcode) {
      _openBarcodeScanner();
    } else if (_mode == _ScanMode.image) {
      _openImageCamera();
    }
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      await _repository.createProduct(
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        purchasePrice: double.parse(_purchasePriceCtrl.text),
        sellingPrice: double.parse(_priceCtrl.text),
        quantity: int.parse(_qtyCtrl.text),
        barcode: _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
        imageUrl: _savedImagePath,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr.productSaved),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } on RepositoryException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr.addProduct)),
      body: Column(
        children: [
          // Mode selector
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            child: Row(
              children: _ScanMode.values.map((m) {
                final isActive = _mode == m;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: m != _ScanMode.values.last ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() { _mode = m; _scanned = false; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(
                            color: isActive ? AppColors.primary : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(m.icon, size: 20, color: isActive ? Colors.white : null),
                            const SizedBox(height: 2),
                            Text(
                              m.label(context),
                              style: textTheme.labelSmall?.copyWith(
                                color: isActive ? Colors.white : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMD),
              child: Column(
                children: [
                  // Scanner viewport
                  if (!_scanned) ...[
                    _ScannerViewport(mode: _mode, onActivate: _handleActivate),
                    const SizedBox(height: 24),
                  ],

                  // Product form (shown after scan or for manual entry)
                  if (_scanned || _mode == _ScanMode.manual) ...[
                    if (_scanned) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _mode == _ScanMode.barcode
                                  ? tr.barcodeScanned
                                  : tr.productDetected,
                              style: textTheme.bodySmall?.copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_pickedImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Image.file(
                              File(_savedImagePath ?? _pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            label: tr.productName,
                            hint: tr.productNameHint,
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v?.isEmpty ?? true) ? tr.required : null,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: tr.category,
                            hint: tr.categoryHint,
                            controller: _categoryCtrl,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v?.isEmpty ?? true) ? tr.required : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: tr.purchasePrice,
                                  hint: '0.00',
                                  controller: _purchasePriceCtrl,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v?.isEmpty ?? true) ? tr.required : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  label: tr.sellingPrice,
                                  hint: '0.00',
                                  controller: _priceCtrl,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v?.isEmpty ?? true) ? tr.required : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: tr.quantity,
                                  hint: '0',
                                  controller: _qtyCtrl,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v?.isEmpty ?? true) ? tr.required : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  label: tr.barcodeOptional,
                                  hint: tr.barcode,
                                  controller: _barcodeCtrl,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            label: tr.saveProduct,
                            onPressed: _saveProduct,
                            isLoading: _isSaving,
                            leading: const Icon(Icons.check_rounded, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerViewport extends StatelessWidget {
  const _ScannerViewport({required this.mode, required this.onActivate});
  final _ScanMode mode;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Scan frame
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(mode.icon, size: 40, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                mode == _ScanMode.barcode
                    ? tr.pointAtBarcode
                    : mode == _ScanMode.image
                        ? tr.pointAtProduct
                        : tr.enterDetails,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onActivate,
                icon: const Icon(Icons.center_focus_strong_rounded),
                label: Text(tr.openCamera),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ScanMode {
  barcode,
  image,
  manual;

  String label(BuildContext context) {
    switch (this) {
      case barcode: return context.tr.scanModeBarcode;
      case image: return context.tr.scanModeImage;
      case manual: return context.tr.scanModeManual;
    }
  }

  IconData get icon {
    switch (this) {
      case barcode: return Icons.qr_code_scanner_rounded;
      case image: return Icons.image_search_rounded;
      case manual: return Icons.edit_note_rounded;
    }
  }
}
