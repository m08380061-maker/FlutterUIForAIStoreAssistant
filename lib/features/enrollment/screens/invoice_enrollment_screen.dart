import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/ocr_service.dart';
import '../../../shared/services/product_draft_service.dart';
import '../../../shared/services/web_image_service.dart';
import '../../../shared/widgets/custom_button.dart';

class InvoiceEnrollmentScreen extends StatefulWidget {
  const InvoiceEnrollmentScreen({super.key});

  @override
  State<InvoiceEnrollmentScreen> createState() => _InvoiceEnrollmentScreenState();
}

class _InvoiceEnrollmentScreenState extends State<InvoiceEnrollmentScreen> {
  final _picker = ImagePicker();
  String? _invoiceImagePath;
  bool _isProcessing = false;
  bool _isEnriching = false;
  OcrResult? _ocrResult;
  List<ExtractedItem> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Scaffold(
      appBar: AppBar(title: Text(tr.enrollByInvoice), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: _captureInvoice,
            child: Container(
              width: double.infinity, height: 200,
              decoration: BoxDecoration(color: AppColors.accentOrange.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppConstants.radiusMedium), border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.2))),
              child: _invoiceImagePath != null ? ClipRRect(borderRadius: BorderRadius.circular(AppConstants.radiusMedium), child: Image.file(File(_invoiceImagePath!), fit: BoxFit.cover)) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.accentOrange), const SizedBox(height: 8), Text(tr.captureInvoice, style: Theme.of(context).textTheme.bodyMedium)]),
            ),
          ),
          if (_invoiceImagePath == null) ...[const SizedBox(height: 8), Center(child: TextButton.icon(onPressed: _pickInvoiceGallery, icon: const Icon(Icons.photo_library_rounded, size: 18), label: Text(tr.pickFromGallery)))],
          const SizedBox(height: 20),
          if (_isProcessing) ...[Center(child: Column(children: [const CircularProgressIndicator(), const SizedBox(height: 8), Text(tr.processingInvoice, style: Theme.of(context).textTheme.bodyMedium)]))]
          else if (_ocrResult != null) ...[
            if (_ocrResult!.items.isEmpty) ...[
              Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppConstants.radiusMedium)), child: Column(children: [Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 32), const SizedBox(height: 8), Text(tr.noItemsExtracted, style: Theme.of(context).textTheme.bodyMedium)])),
            ] else ...[
              Text(tr.extractedItems, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('${_ocrResult!.items.length} ${tr.itemsFound}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
              const SizedBox(height: 12),
              ..._ocrResult!.items.asMap().entries.map((entry) {
                final item = entry.value;
                final isSelected = _selectedItems.contains(item);
                return _ExtractedItemCard(item: item, isSelected: isSelected, onToggle: () => setState(() { if (isSelected) { _selectedItems.remove(item); } else { _selectedItems.add(item); } }));
              }),
              const SizedBox(height: 20),
              if (_isEnriching) Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 8), Text(tr.enrichingImages, style: Theme.of(context).textTheme.bodySmall)])),
              CustomButton(label: tr.createDraftsFromItems, onPressed: _isEnriching ? null : _createDrafts, isLoading: _isEnriching),
            ],
          ],
        ]),
      ),
    );
  }

  Future<void> _captureInvoice() async {
    final xFile = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024);
    if (xFile == null) return;
    setState(() { _invoiceImagePath = xFile.path; _ocrResult = null; _selectedItems = []; });
    await _processOcr();
  }

  Future<void> _pickInvoiceGallery() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (xFile == null) return;
    setState(() { _invoiceImagePath = xFile.path; _ocrResult = null; _selectedItems = []; });
    await _processOcr();
  }

  Future<void> _processOcr() async {
    if (_invoiceImagePath == null) return;
    setState(() => _isProcessing = true);
    try {
      final result = await OcrService.instance.processInvoice(_invoiceImagePath!);
      setState(() { _ocrResult = result; _selectedItems = List.from(result.items); });
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _createDrafts() async {
    if (_selectedItems.isEmpty) return;
    setState(() => _isEnriching = true);
    try {
      for (final item in _selectedItems) {
        final images = await WebImageService.instance.searchProductImages(item.name);
        await WebImageService.instance.downloadAndSaveMultiple(images.map((r) => r.url).toList(), max: 1);
        await ProductDraftService.instance.createDraft(name: item.name, quantity: item.quantity, purchasePrice: item.price, source: DraftSource.invoice, sourceImagePath: _invoiceImagePath, extractedData: item.toJson());
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_selectedItems.length} ${context.tr.draftsCreated}'), backgroundColor: AppColors.success));
        context.go('/enrollment');
      }
    } finally {
      if (mounted) setState(() => _isEnriching = false);
    }
  }
}

class _ExtractedItemCard extends StatelessWidget {
  const _ExtractedItemCard({required this.item, required this.isSelected, required this.onToggle});
  final ExtractedItem item;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(AppConstants.radiusSmall), border: Border.all(color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent)),
        child: Row(children: [
          Icon(isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)), if (item.quantity != null || item.price != null) ...[const SizedBox(height: 2), Text([if (item.quantity != null) '${tr.qty}: ${item.quantity}', if (item.price != null) tr.formatCurrency(item.price!)].join(' · '), style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline))]])),
        ]),
      ),
    );
  }
}
