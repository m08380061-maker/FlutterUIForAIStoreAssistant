import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class DraftReviewScreen extends StatefulWidget {
  final String draftId;
  const DraftReviewScreen({super.key, required this.draftId});
  @override
  State<DraftReviewScreen> createState() => _DraftReviewScreenState();
}

class _DraftReviewScreenState extends State<DraftReviewScreen> {
  DraftProduct? _draft;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEnriching = false;
  List<String> _enrichedImages = [];
  final _nameCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() { super.initState(); _loadDraft(); }
  @override
  void dispose() { _nameCtrl.dispose(); _barcodeCtrl.dispose(); _categoryCtrl.dispose(); _purchasePriceCtrl.dispose(); _sellingPriceCtrl.dispose(); _quantityCtrl.dispose(); _descriptionCtrl.dispose(); super.dispose(); }

  Future<void> _loadDraft() async {
    final draft = await ProductDraftService.instance.getDraft(widget.draftId);
    if (draft == null) { if (mounted) context.pop(); return; }
    _draft = draft;
    _nameCtrl.text = draft.name;
    _barcodeCtrl.text = draft.barcode ?? '';
    _categoryCtrl.text = draft.category ?? '';
    _purchasePriceCtrl.text = draft.purchasePrice?.toString() ?? '';
    _sellingPriceCtrl.text = draft.sellingPrice?.toString() ?? '';
    _quantityCtrl.text = draft.quantity?.toString() ?? '1';
    _descriptionCtrl.text = draft.description ?? '';
    setState(() => _isLoading = false);
  }

  Future<void> _enrichImages() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isEnriching = true);
    try {
      final results = await WebImageService.instance.searchProductImages(_nameCtrl.text.trim());
      final downloaded = await WebImageService.instance.downloadAndSaveMultiple(results.map((r) => r.url).toList(), max: 3);
      setState(() => _enrichedImages = downloaded);
    } finally { if (mounted) setState(() => _isEnriching = false); }
  }

  Future<void> _saveAsProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_draft == null) return;
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
      final allImages = <String>[if (_draft!.sourceImagePath != null) _draft!.sourceImagePath!, ..._enrichedImages];
      for (var i = 0; i < allImages.length; i++) {
        await ProductImageService.instance.saveImage(productId: product.id, localPath: allImages[i], isPrimary: i == 0);
      }
      if (allImages.isNotEmpty) {
        final fp = await FingerprintService.instance.generateFromFile(allImages[0]);
        await ProductIndexService.instance.storeEmbedding(productId: product.id, fingerprint: fp);
      }
      await ProductDraftService.instance.markCompleted(_draft!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr.productSaved), backgroundColor: AppColors.success));
        context.go('/inventory');
      }
    } on RepositoryException catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: AppColors.error)); }
    } finally { if (mounted) setState(() => _isSaving = false); }
  }

  Future<void> _deleteDraft() async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text(context.tr.deleteDraft), content: Text(context.tr.deleteDraftConfirm), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr.cancel)), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.tr.delete))])) ?? false;
    if (!confirmed) return;
    await ProductDraftService.instance.deleteDraft(widget.draftId);
    if (mounted) context.go('/enrollment');
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    if (_isLoading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(tr.reviewDraft), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()), actions: [IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: _deleteDraft, tooltip: tr.deleteDraft)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_draft!.sourceImagePath != null) ...[ClipRRect(borderRadius: BorderRadius.circular(AppConstants.radiusMedium), child: Image.file(File(_draft!.sourceImagePath!), width: double.infinity, height: 180, fit: BoxFit.cover)), const SizedBox(height: 16)],
            if (_draft!.source == DraftSource.invoice && _draft!.extractedData != null) ...[
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.accentOrange.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppConstants.radiusSmall)), child: Row(children: [Icon(Icons.receipt_long_rounded, color: AppColors.accentOrange, size: 20), const SizedBox(width: 8), Expanded(child: Text('${tr.extractedFromInvoice}: ${_draft!.extractedData!['name']}${_draft!.extractedData!['quantity'] != null ? ' (${_draft!.extractedData!['quantity']} ${tr.units})' : ''}', style: Theme.of(context).textTheme.bodySmall))])),
              const SizedBox(height: 16),
            ],
            CustomTextField(label: tr.productName, controller: _nameCtrl, validator: (v) => (v?.trim().isEmpty ?? true) ? tr.required : null),
            const SizedBox(height: 12),
            CustomTextField(label: tr.barcodeOptional, controller: _barcodeCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            CustomTextField(label: tr.category, controller: _categoryCtrl, hintText: 'Uncategorized'),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: CustomTextField(label: tr.purchasePrice, controller: _purchasePriceCtrl, keyboardType: TextInputType.number)), const SizedBox(width: 12), Expanded(child: CustomTextField(label: tr.sellingPrice, controller: _sellingPriceCtrl, keyboardType: TextInputType.number))]),
            const SizedBox(height: 12),
            CustomTextField(label: tr.quantity, controller: _quantityCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            CustomTextField(label: tr.descriptionOptional, controller: _descriptionCtrl, maxLines: 3),
            const SizedBox(height: 20),
            if (_enrichedImages.isNotEmpty) ...[
              Text(tr.foundImages, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _enrichedImages.length, itemBuilder: (ctx, i) => Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppConstants.radiusSmall), image: DecorationImage(image: FileImage(File(_enrichedImages[i])), fit: BoxFit.cover))))),
              const SizedBox(height: 20),
            ],
            if (_isEnriching) Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 8), Text(tr.searchingWeb, style: Theme.of(context).textTheme.bodySmall)])),
            OutlinedButton.icon(onPressed: _isEnriching ? null : _enrichImages, icon: const Icon(Icons.search_rounded), label: Text(tr.searchWebImages)),
            const SizedBox(height: 12),
            CustomButton(label: tr.saveAsProduct, onPressed: _isSaving ? null : _saveAsProduct, isLoading: _isSaving),
          ]),
        ),
      ),
    );
  }
}
