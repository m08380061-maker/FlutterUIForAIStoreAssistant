import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/services/fingerprint_service.dart';
import '../../../shared/services/product_draft_service.dart';
import '../../../shared/services/product_image_service.dart';
import '../../../shared/services/product_index_service.dart';
import '../../../shared/services/web_image_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class PhotoEnrollmentScreen extends StatefulWidget {
  const PhotoEnrollmentScreen({super.key});

  @override
  State<PhotoEnrollmentScreen> createState() => _PhotoEnrollmentScreenState();
}

class _PhotoEnrollmentScreenState extends State<PhotoEnrollmentScreen> {
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String? _capturedImagePath;
  List<String> _enrichedImages = [];
  bool _isSearching = false;
  bool _isSaving = false;
  bool _createAsDraft = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    final xFile = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024);
    if (xFile == null) return;
    setState(() => _capturedImagePath = xFile.path);
  }

  Future<void> _pickFromGallery() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (xFile == null) return;
    setState(() => _capturedImagePath = xFile.path);
  }

  Future<void> _enrichFromName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty && _capturedImagePath == null) return;
    setState(() => _isSearching = true);
    try {
      final query = name.isNotEmpty ? name : 'product';
      final results = await WebImageService.instance.searchProductImages(query);
      final downloaded = await WebImageService.instance.downloadAndSaveMultiple(results.map((r) => r.url).toList(), max: 3);
      setState(() => _enrichedImages = downloaded);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  bool get _hasMissingFields {
    return _categoryCtrl.text.trim().isEmpty || _purchasePriceCtrl.text.trim().isEmpty || _sellingPriceCtrl.text.trim().isEmpty;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr.productNameRequired), backgroundColor: AppColors.error));
      return;
    }
    if (_hasMissingFields) {
      setState(() => _createAsDraft = true);
    }
    setState(() => _isSaving = true);
    try {
      if (_createAsDraft) {
        await ProductDraftService.instance.createDraft(
          name: _nameCtrl.text.trim(),
          category: _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
          purchasePrice: double.tryParse(_purchasePriceCtrl.text),
          sellingPrice: double.tryParse(_sellingPriceCtrl.text),
          quantity: int.tryParse(_quantityCtrl.text),
          source: DraftSource.photo,
          sourceImagePath: _capturedImagePath,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr.draftCreated), backgroundColor: AppColors.warning));
          context.go('/enrollment');
        }
        return;
      }
      final repo = ProductRepository();
      final product = await repo.createProduct(
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim().isEmpty ? 'Uncategorized' : _categoryCtrl.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceCtrl.text) ?? 0,
        sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 0,
        quantity: int.tryParse(_quantityCtrl.text) ?? 0,
      );
      final allImages = <String>[
        if (_capturedImagePath != null) _capturedImagePath!,
        ..._enrichedImages,
      ];
      for (var i = 0; i < allImages.length; i++) {
        await ProductImageService.instance.saveImage(productId: product.id, localPath: allImages[i], isPrimary: i == 0);
      }
      if (allImages.isNotEmpty) {
        final fp = await FingerprintService.instance.generateFromFile(allImages[0]);
        await ProductIndexService.instance.storeEmbedding(productId: product.id, fingerprint: fp);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr.productSaved), backgroundColor: AppColors.success));
        context.go('/inventory');
      }
    } on RepositoryException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: AppColors.error));
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
        title: Text(tr.enrollByPhoto),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: _capturedImagePath != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(AppConstants.radiusMedium), child: Image.file(File(_capturedImagePath!), fit: BoxFit.cover))
                      : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.primary), const SizedBox(height: 8), Text(tr.tapToCapture, style: Theme.of(context).textTheme.bodyMedium)]),
                ),
              ),
              if (_capturedImagePath == null) ...[
                const SizedBox(height: 8),
                Center(child: TextButton.icon(onPressed: _pickFromGallery, icon: const Icon(Icons.photo_library_rounded, size: 18), label: Text(tr.pickFromGallery))),
              ],
              const SizedBox(height: 20),
              CustomTextField(label: tr.productName, controller: _nameCtrl, validator: (v) => (v?.trim().isEmpty ?? true) ? tr.required : null),
              const SizedBox(height: 12),
              CustomTextField(label: tr.category, controller: _categoryCtrl, hintText: tr.optionalField),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: CustomTextField(label: tr.purchasePrice, controller: _purchasePriceCtrl, keyboardType: TextInputType.number)), const SizedBox(width: 12), Expanded(child: CustomTextField(label: tr.sellingPrice, controller: _sellingPriceCtrl, keyboardType: TextInputType.number))]),
              const SizedBox(height: 12),
              CustomTextField(label: tr.quantity, controller: _quantityCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              if (_enrichedImages.isNotEmpty) ...[
                Text(tr.foundImages, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _enrichedImages.length, itemBuilder: (ctx, i) => Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppConstants.radiusSmall), image: DecorationImage(image: FileImage(File(_enrichedImages[i])), fit: BoxFit.cover))))),
                const SizedBox(height: 20),
              ],
              if (_isSearching) Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 8), Text(tr.searchingWeb, style: Theme.of(context).textTheme.bodySmall)])),
              OutlinedButton.icon(onPressed: _isSearching ? null : _enrichFromName, icon: const Icon(Icons.search_rounded), label: Text(tr.searchWebImages)),
              const SizedBox(height: 12),
              if (_hasMissingFields && _nameCtrl.text.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning), const SizedBox(width: 6), Expanded(child: Text(tr.incompleteFieldsDraft, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)))])),
              CustomButton(label: _hasMissingFields ? tr.saveAsDraft : tr.saveProduct, onPressed: _isSaving ? null : _save, isLoading: _isSaving),
            ],
          ),
        ),
      ),
    );
  }
}
