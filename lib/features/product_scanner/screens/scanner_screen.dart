import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/ai_assistant/services/vision_command_router.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  _ScanMode _mode = _ScanMode.barcode;
  bool _scanned = false;
  bool _isSaving = false;
  bool _cameraActive = false;
  String? _capturedImagePath;
  final ProductRepository _repository = ProductRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _qtyCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _startBarcodeScanner() async {
    setState(() => _cameraActive = true);
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final barcode = barcodes.first.rawValue;
    if (barcode == null || barcode.isEmpty) return;
    setState(() {
      _cameraActive = false;
      _scanned = true;
      _barcodeCtrl.text = barcode;
      _nameCtrl.text = 'Product $barcode';
      _categoryCtrl.text = 'General';
      _priceCtrl.text = '';
      _purchasePriceCtrl.text = '';
      _qtyCtrl.text = '1';
    });
    _lookupProductByBarcode(barcode);
  }

  Future<void> _lookupProductByBarcode(String barcode) async {
    try {
      final products = await _repository.getAllProducts();
      final match = products.where((p) => p.barcode == barcode).firstOrNull;
      if (match != null) {
        setState(() {
          _nameCtrl.text = match.name;
          _categoryCtrl.text = match.category;
          _priceCtrl.text = match.sellingPrice.toStringAsFixed(0);
          _purchasePriceCtrl.text = match.purchasePrice.toStringAsFixed(0);
          _qtyCtrl.text = '1';
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (xFile == null) return;
    setState(() {
      _capturedImagePath = xFile.path;
      _scanned = true;
    });
    final bytes = await File(xFile.path).readAsBytes();
    final result = await VisionCommandRouter.instance.analyzeImage(bytes);
    if (!mounted) return;
    if (result.success && result.productName != null) {
      setState(() {
        _nameCtrl.text = result.productName ?? '';
        _categoryCtrl.text = result.category ?? 'General';
      });
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
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "${_nameCtrl.text}" saved successfully!'),
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
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            child: Row(
              children: _ScanMode.values.map((m) {
                final isActive = _mode == m;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: m != _ScanMode.values.last ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _mode = m;
                        _scanned = false;
                        _cameraActive = false;
                        _capturedImagePath = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(color: isActive ? AppColors.primary : Theme.of(context).colorScheme.outline),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(m.icon, size: 20, color: isActive ? Colors.white : null),
                            const SizedBox(height: 2),
                            Text(m.label, style: textTheme.labelSmall?.copyWith(color: isActive ? Colors.white : null)),
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
                  if (!_scanned && _mode == _ScanMode.barcode) ...[
                    if (_cameraActive)
                      SizedBox(
                        height: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                          child: MobileScanner(onDetect: _onBarcodeDetected),
                        ),
                      )
                    else
                      _ScannerPlaceholder(
                        icon: Icons.qr_code_scanner_rounded,
                        text: 'Point camera at barcode',
                        buttonText: 'Open Camera',
                        onTap: _startBarcodeScanner,
                      ),
                    const SizedBox(height: 24),
                  ],
                  if (!_scanned && _mode == _ScanMode.image) ...[
                    if (_capturedImagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        child: Image.file(
                          File(_capturedImagePath!),
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      _ScannerPlaceholder(
                        icon: Icons.image_search_rounded,
                        text: 'Take a photo of the product',
                        buttonText: 'Open Camera',
                        onTap: _pickImage,
                      ),
                    const SizedBox(height: 24),
                  ],
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
                            Expanded(
                              child: Text(
                                _mode == _ScanMode.barcode
                                    ? 'Barcode scanned! Confirm product details below.'
                                    : 'Photo captured! Confirm details below.',
                                style: textTheme.bodySmall?.copyWith(color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_capturedImagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        child: Image.file(
                          File(_capturedImagePath!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            label: 'Product Name',
                            hint: 'e.g. Rice (5kg)',
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Category',
                            hint: 'e.g. Grains',
                            controller: _categoryCtrl,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Purchase Price (YER)',
                                  hint: '0.00',
                                  controller: _purchasePriceCtrl,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  label: 'Selling Price (YER)',
                                  hint: '0.00',
                                  controller: _priceCtrl,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Quantity',
                                  hint: '0',
                                  controller: _qtyCtrl,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  label: 'Barcode (optional)',
                                  hint: 'Scan or enter',
                                  controller: _barcodeCtrl,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            label: 'Save Product',
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

class _ScannerPlaceholder extends StatelessWidget {
  const _ScannerPlaceholder({
    required this.icon,
    required this.text,
    required this.buttonText,
    required this.onTap,
  });
  final IconData icon;
  final String text;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.center_focus_strong_rounded),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
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

  String get label => switch (this) {
        barcode => 'Barcode',
        image => 'Image',
        manual => 'Manual',
      };

  IconData get icon => switch (this) {
        barcode => Icons.qr_code_scanner_rounded,
        image => Icons.image_search_rounded,
        manual => Icons.edit_note_rounded,
      };
}
