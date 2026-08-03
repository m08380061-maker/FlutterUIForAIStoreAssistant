/// Enrollment-specific translation keys.
library;

import 'package:flutter/material.dart';

import 'app_translations.dart';
import '../../shared/services/storage_service.dart';

/// Provides enrollment-specific translations.
/// Usage: `EnrollmentTranslations.of(context).enrollByBarcode`
class EnrollmentTranslations {
  final String _lang;

  EnrollmentTranslations._(this._lang);

  static EnrollmentTranslations of(BuildContext context) {
    final lang = LocaleProvider.instance.locale.languageCode;
    return EnrollmentTranslations._(lang);
  }

  String _s(String key) {
    final map = _lang == 'ar' ? _ar : _en;
    return map[key] ?? key;
  }

  String get enrollProductTitle => _s('enrollProductTitle');
  String get enrollProductSubtitle => _s('enrollProductSubtitle');
  String get enrollByBarcode => _s('enrollByBarcode');
  String get enrollByBarcodeDesc => _s('enrollByBarcodeDesc');
  String get enrollByPhoto => _s('enrollByPhoto');
  String get enrollByPhotoDesc => _s('enrollByPhotoDesc');
  String get enrollByInvoice => _s('enrollByInvoice');
  String get enrollByInvoiceDesc => _s('enrollByInvoiceDesc');
  String get enrollManual => _s('enrollManual');
  String get enrollManualDesc => _s('enrollManualDesc');
  String get barcodeEnterHint => _s('barcodeEnterHint');
  String get searchingWeb => _s('searchingWeb');
  String get searchWebImages => _s('searchWebImages');
  String get foundImages => _s('foundImages');
  String get tapToCapture => _s('tapToCapture');
  String get pickFromGallery => _s('pickFromGallery');
  String get optionalField => _s('optionalField');
  String get incompleteFieldsDraft => _s('incompleteFieldsDraft');
  String get saveAsDraft => _s('saveAsDraft');
  String get saveAsProduct => _s('saveAsProduct');
  String get draftCreated => _s('draftCreated');
  String get draftsCreated => _s('draftsCreated');
  String get pendingDrafts => _s('pendingDrafts');
  String get reviewDraft => _s('reviewDraft');
  String get deleteDraft => _s('deleteDraft');
  String get deleteDraftConfirm => _s('deleteDraftConfirm');
  String get productNameRequired => _s('productNameRequired');
  String get captureInvoice => _s('captureInvoice');
  String get processingInvoice => _s('processingInvoice');
  String get extractedItems => _s('extractedItems');
  String get itemsFound => _s('itemsFound');
  String get noItemsExtracted => _s('noItemsExtracted');
  String get createDraftsFromItems => _s('createDraftsFromItems');
  String get enrichingImages => _s('enrichingImages');
  String get extractedFromInvoice => _s('extractedFromInvoice');

  static const Map<String, String> _en = {
    'enrollProductTitle': 'Add a Product',
    'enrollProductSubtitle': 'Choose how you want to add a new product to your store.',
    'enrollByBarcode': 'Barcode',
    'enrollByBarcodeDesc': 'Enter or scan a barcode',
    'enrollByPhoto': 'Product Photo',
    'enrollByPhotoDesc': 'Take a photo and enrich from the web',
    'enrollByInvoice': 'Invoice Photo',
    'enrollByInvoiceDesc': 'OCR extract items from an invoice',
    'enrollManual': 'Manual Entry',
    'enrollManualDesc': 'Type in all product details yourself',
    'barcodeEnterHint': 'Type the barcode number below.',
    'searchingWeb': 'Searching the web...',
    'searchWebImages': 'Search Web Images',
    'foundImages': 'Found Images',
    'tapToCapture': 'Tap to capture a photo',
    'pickFromGallery': 'Pick from gallery',
    'optionalField': 'Optional',
    'incompleteFieldsDraft': 'Some fields are missing. This will be saved as a draft you can complete later.',
    'saveAsDraft': 'Save as Draft',
    'saveAsProduct': 'Save as Product',
    'draftCreated': 'Draft created. You can complete it later.',
    'draftsCreated': 'drafts created',
    'pendingDrafts': 'Pending Drafts',
    'reviewDraft': 'Review Draft',
    'deleteDraft': 'Delete Draft',
    'deleteDraftConfirm': 'Delete this draft permanently?',
    'productNameRequired': 'Product name is required.',
    'captureInvoice': 'Capture or upload an invoice',
    'processingInvoice': 'Processing invoice with OCR...',
    'extractedItems': 'Extracted Items',
    'itemsFound': 'items found',
    'noItemsExtracted': 'No items could be extracted. Try a clearer photo.',
    'createDraftsFromItems': 'Create Drafts from Selected Items',
    'enrichingImages': 'Fetching product images...',
    'extractedFromInvoice': 'Extracted from invoice',
  };

  static const Map<String, String> _ar = {
    'enrollProductTitle': 'إضافة منتج',
    'enrollProductSubtitle': 'اختر كيف تريد إضافة منتج جديد إلى متجرك.',
    'enrollByBarcode': 'باركود',
    'enrollByBarcodeDesc': 'أدخل أو امسح الباركود',
    'enrollByPhoto': 'صورة المنتج',
    'enrollByPhotoDesc': 'التقط صورة وأثرِها من الويب',
    'enrollByInvoice': 'صورة الفاتورة',
    'enrollByInvoiceDesc': 'استخراج العناصر بالـ OCR من الفاتورة',
    'enrollManual': 'إدخال يدوي',
    'enrollManualDesc': 'اكتب جميع تفاصيل المنتج بنفسك',
    'barcodeEnterHint': 'اكتب رقم الباركود بالأسفل.',
    'searchingWeb': 'جارٍ البحث في الويب...',
    'searchWebImages': 'بحث عن صور',
    'foundImages': 'الصور التي تم العثور عليها',
    'tapToCapture': 'اضغط لالتقاط صورة',
    'pickFromGallery': 'اختر من المعرض',
    'optionalField': 'اختياري',
    'incompleteFieldsDraft': 'بعض الحقول ناقصة. سيتم الحفظ كمسودة يمكنك إكمالها لاحقاً.',
    'saveAsDraft': 'حفظ كمسودة',
    'saveAsProduct': 'حفظ كمنتج',
    'draftCreated': 'تم إنشاء المسودة. يمكنك إكمالها لاحقاً.',
    'draftsCreated': 'مسودة تم إنشاؤها',
    'pendingDrafts': 'المسودات المعلقة',
    'reviewDraft': 'مراجعة المسودة',
    'deleteDraft': 'حذف المسودة',
    'deleteDraftConfirm': 'حذف هذه المسودة نهائياً؟',
    'productNameRequired': 'اسم المنتج مطلوب.',
    'captureInvoice': 'التقط أو ارفع فاتورة',
    'processingInvoice': 'جارٍ معالجة الفاتورة بالـ OCR...',
    'extractedItems': 'العناصر المستخرجة',
    'itemsFound': 'عنصر موجود',
    'noItemsExtracted': 'تعذّر استخراج أي عناصر. جرّب صورة أوضح.',
    'createDraftsFromItems': 'إنشاء مسودات من العناصر المحددة',
    'enrichingImages': 'جارٍ جلب صور المنتج...',
    'extractedFromInvoice': 'مستخرج من الفاتورة',
  };
}
