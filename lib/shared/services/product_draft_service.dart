import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';

enum DraftSource { barcode, photo, invoice, manual }

class DraftProduct {
  final String id;
  final String name;
  final String? barcode;
  final String? category;
  final double? purchasePrice;
  final double? sellingPrice;
  final int? quantity;
  final String? description;
  final DraftSource source;
  final String? sourceImagePath;
  final Map<String, dynamic>? extractedData;
  final int completionPercent;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DraftProduct({
    required this.id,
    required this.name,
    this.barcode,
    this.category,
    this.purchasePrice,
    this.sellingPrice,
    this.quantity,
    this.description,
    required this.source,
    this.sourceImagePath,
    this.extractedData,
    this.completionPercent = 0,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DraftProduct copyWith({
    String? id,
    String? name,
    String? barcode,
    String? category,
    double? purchasePrice,
    double? sellingPrice,
    int? quantity,
    String? description,
    DraftSource? source,
    String? sourceImagePath,
    Map<String, dynamic>? extractedData,
    int? completionPercent,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DraftProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      source: source ?? this.source,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      extractedData: extractedData ?? this.extractedData,
      completionPercent: completionPercent ?? this.completionPercent,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProductDraftService {
  ProductDraftService._();
  static final ProductDraftService instance = ProductDraftService._();

  final _db = AppDatabase.instance;

  Future<DraftProduct> createDraft({
    required String name,
    required DraftSource source,
    String? barcode,
    String? category,
    double? purchasePrice,
    double? sellingPrice,
    int? quantity,
    String? description,
    String? sourceImagePath,
    Map<String, dynamic>? extractedData,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final completion = _calcCompletion(name, barcode, category, purchasePrice, sellingPrice, quantity);

    await _db.customStatement(
      'INSERT INTO product_drafts (id, name, barcode, category, purchase_price, selling_price, quantity, description, source_type, source_image_path, extracted_data, completion_percent, is_completed, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        name,
        barcode,
        category,
        purchasePrice,
        sellingPrice,
        quantity,
        description,
        source.name,
        sourceImagePath,
        extractedData != null ? jsonEncode(extractedData) : null,
        completion,
        0,
        now.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      ],
    );

    return DraftProduct(
      id: id,
      name: name,
      barcode: barcode,
      category: category,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      quantity: quantity,
      description: description,
      source: source,
      sourceImagePath: sourceImagePath,
      extractedData: extractedData,
      completionPercent: completion,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<DraftProduct?> getDraft(String id) async {
    final rows = await _db.customSelect(
      'SELECT * FROM product_drafts WHERE id = ?',
      variables: [Variable<String>(id)],
    ).get();
    if (rows.isEmpty) return null;
    return _mapRow(rows.first);
  }

  Future<List<DraftProduct>> getPendingDrafts() async {
    final rows = await _db.customSelect(
      'SELECT * FROM product_drafts WHERE is_completed = 0 ORDER BY updated_at DESC',
    ).get();
    return rows.map(_mapRow).toList();
  }

  Future<List<DraftProduct>> getAllDrafts() async {
    final rows = await _db.customSelect(
      'SELECT * FROM product_drafts ORDER BY updated_at DESC',
    ).get();
    return rows.map(_mapRow).toList();
  }

  Future<void> updateDraft(DraftProduct draft) async {
    final completion = _calcCompletion(
      draft.name, draft.barcode, draft.category,
      draft.purchasePrice, draft.sellingPrice, draft.quantity,
    );
    await _db.customStatement(
      'UPDATE product_drafts SET name = ?, barcode = ?, category = ?, purchase_price = ?, selling_price = ?, quantity = ?, description = ?, extracted_data = ?, completion_percent = ?, is_completed = ?, updated_at = ? WHERE id = ?',
      [
        draft.name,
        draft.barcode,
        draft.category,
        draft.purchasePrice,
        draft.sellingPrice,
        draft.quantity,
        draft.description,
        draft.extractedData != null ? jsonEncode(draft.extractedData) : null,
        completion,
        draft.isCompleted ? 1 : 0,
        DateTime.now().millisecondsSinceEpoch,
        draft.id,
      ],
    );
  }

  Future<void> markCompleted(String id) async {
    await _db.customStatement(
      'UPDATE product_drafts SET is_completed = 1, updated_at = ? WHERE id = ?',
      [DateTime.now().millisecondsSinceEpoch, id],
    );
  }

  Future<void> deleteDraft(String id) async {
    await _db.customStatement(
      'DELETE FROM product_drafts WHERE id = ?',
      [id],
    );
  }

  DraftProduct _mapRow(TypedResult row) {
    final raw = row.raw;
    return DraftProduct(
      id: raw['id'] as String,
      name: raw['name'] as String,
      barcode: raw['barcode'] as String?,
      category: raw['category'] as String?,
      purchasePrice: raw['purchase_price'] as double?,
      sellingPrice: raw['selling_price'] as double?,
      quantity: raw['quantity'] as int?,
      description: raw['description'] as String?,
      source: DraftSource.values.firstWhere(
        (s) => s.name == raw['source_type'] as String,
        orElse: () => DraftSource.manual,
      ),
      sourceImagePath: raw['source_image_path'] as String?,
      extractedData: raw['extracted_data'] != null
          ? jsonDecode(raw['extracted_data'] as String) as Map<String, dynamic>
          : null,
      completionPercent: raw['completion_percent'] as int,
      isCompleted: (raw['is_completed'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(raw['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(raw['updated_at'] as int),
    );
  }

  int _calcCompletion(
    String? name, String? barcode, String? category,
    double? purchasePrice, double? sellingPrice, int? quantity,
  ) {
    var filled = 0;
    const total = 6;
    if (name != null && name.trim().isNotEmpty) filled++;
    if (barcode != null && barcode.trim().isNotEmpty) filled++;
    if (category != null && category.trim().isNotEmpty) filled++;
    if (purchasePrice != null) filled++;
    if (sellingPrice != null) filled++;
    if (quantity != null) filled++;
    return (filled / total * 100).round();
  }
}
