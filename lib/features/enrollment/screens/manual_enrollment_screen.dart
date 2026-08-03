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

class ManualEnrollmentScreen extends StatefulWidget {
  const ManualEnrollmentScreen({super.key});

  @override
  State<ManualEnrollmentScreen> createState() => _ManualEnrollmentScreenState();
}

class _ManualEnrollmentScreenState extends State<ManualEnrollmentScreen> {
  final _nameCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _descriptionCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isSearching = false;
  List<String> _enrichedImages = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _barcodeCtrl.dispose();
    _categoryCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _quantityCtrl.dispose();
    _descriptionCtrl.dispose();
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
        category: _categoryCtrl.text.trim().isEmpty ? 'Uncategorized' : _categoryCtrl.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceCtrl.text) ?? 0,
        sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 0,
        quantity: int.tryParse(_quantityCtrl.text) ?? 0,
        barcode: _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
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
        title: Text(tr.enrollManual),
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
              CustomTextField(
                label: tr.productName,
                controller: _nameCtrl,
                validator: (v) => (v?.trim().isEmpty ?? true) ? tr.required : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: tr.barcodeOptional,
                controller: _barcodeCtrl,
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 12),
              CustomTextField(
                label: tr.descriptionOptional,
                controller: _descriptionCtrl,
                maxLines: 3,
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
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: const Center(child: Icon(Icons.image_rounded, color: AppColors.primary)),
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

              OutlinedButton.icon(
                onPressed: _isSearching ? null : _searchWebImages,
                icon: const Icon(Icons.search_rounded),
                label: Text(tr.searchWebImages),
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
