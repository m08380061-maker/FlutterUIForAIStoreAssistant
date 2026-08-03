import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/services/fingerprint_service.dart';
import '../../../shared/services/product_image_service.dart';
import '../../../shared/services/product_index_service.dart';
import '../../../shared/services/web_image_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class BarcodeEnrollmentScreen extends StatefulWidget {
  const BarcodeEnrollmentScreen({super.key});

  @override
  State<BarcodeEnrollmentScreen> createState() => _BarcodeEnrollmentScreenState();
}

class _BarcodeEnrollmentScreenState extends State<BarcodeEnrollmentScreen> {
  final _barcodeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();
  bool _isSearching = false;
  bool _isSaving = false;
  List<String> _enrichedImages = [];

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchWebImages() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final results = await WebImageService.instance.searchProductImages(name);
      final downloaded = await WebImageService.instance.downloadAndSaveMultiple(
        results.map((r) => r.url).toList(),
        max: 3,
      );
      setState(() => _enrichedImages = downloaded);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final repo = ProductRepository();
      final product = await repo.createProduct(
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim().isEmpty
            ? 'Uncategorized'
            : _categoryCtrl.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceCtrl.text) ?? 0,
        sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 0,
        quantity: int.tryParse(_quantityCtrl.text) ?? 0,
        barcode: _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
      );

      for (var i = 0; i < _enrichedImages.length; i++) {
        await ProductImageService.instance.saveImage(
          productId: product.id,
          localPath: _enrichedImages[i],
          isPrimary: i == 0,
        );
      }

      if (_enrichedImages.isNotEmpty) {
        final fp = await FingerprintService.instance.generateFromFile(_enrichedImages[0]);
        await ProductIndexService.instance.storeEmbedding(
          productId: product.id,
          fingerprint: fp,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr.productSaved), backgroundColor: AppColors.success),
        );
        context.go('/inventory');
      }
    } on RepositoryException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.enrollByBarcode),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(tr.barcodeEnterHint,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: tr.barcode,
                controller: _barcodeCtrl,
                hintText: '6281234567890',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: tr.productName,
                controller: _nameCtrl,
                validator: (v) => (v?.trim().isEmpty ?? true) ? tr.required : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: tr.category,
                controller: _categoryCtrl,
                hintText: 'Uncategorized',
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: CustomTextField(
                  label: tr.purchasePrice,
                  controller: _purchasePriceCtrl,
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(
                  label: tr.sellingPrice,
                  controller: _sellingPriceCtrl,
                  keyboardType: TextInputType.number,
                )),
              ]),
              const SizedBox(height: 12),
              CustomTextField(
                label: tr.quantity,
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              if (_enrichedImages.isNotEmpty) ...[
                Text(tr.foundImages, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _enrichedImages.length,
                    itemBuilder: (ctx, i) => Container(
                      width: 100, height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        image: DecorationImage(
                          image: FileImage(File(_enrichedImages[i])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text(tr.searchingWeb, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSearching ? null : _searchWebImages,
                      icon: const Icon(Icons.search_rounded),
                      label: Text(tr.searchWebImages),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: tr.saveProduct,
                onPressed: _isSaving ? null : _save,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
