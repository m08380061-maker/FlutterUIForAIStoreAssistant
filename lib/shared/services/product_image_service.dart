import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';

class ProductImageService {
  ProductImageService._();
  static final ProductImageService instance = ProductImageService._();

  final _db = AppDatabase.instance;

  Future<void> saveImage({
    required String productId,
    required String localPath,
    String? sourceUrl,
    int? width,
    int? height,
    bool isPrimary = false,
  }) async {
    await _db.customStatement(
      'INSERT INTO product_images (id, product_id, local_path, source_url, width, height, is_primary, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        const Uuid().v4(),
        productId,
        localPath,
        sourceUrl,
        width,
        height,
        isPrimary ? 1 : 0,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  Future<List<ProductImageRecord>> getImagesForProduct(String productId) async {
    final rows = await _db.customSelect(
      'SELECT * FROM product_images WHERE product_id = ? ORDER BY is_primary DESC, created_at ASC',
      variables: [Variable<String>(productId)],
    ).get();

    return rows.map((row) => ProductImageRecord(
      id: row.read<String>('id'),
      productId: row.read<String>('product_id'),
      localPath: row.read<String>('local_path'),
      sourceUrl: row.read<String?>('source_url'),
      width: row.read<int?>('width'),
      height: row.read<int?>('height'),
      isPrimary: row.read<int>('is_primary') == 1,
    )).toList();
  }

  Future<String?> getPrimaryImage(String productId) async {
    final rows = await _db.customSelect(
      'SELECT local_path FROM product_images WHERE product_id = ? AND is_primary = 1 LIMIT 1',
      variables: [Variable<String>(productId)],
    ).get();
    if (rows.isEmpty) return null;
    return rows.first.read<String>('local_path');
  }

  Future<void> setPrimaryImage(String productId, String imageId) async {
    await _db.customStatement(
      'UPDATE product_images SET is_primary = 0 WHERE product_id = ?',
      [productId],
    );
    await _db.customStatement(
      'UPDATE product_images SET is_primary = 1 WHERE id = ?',
      [imageId],
    );
  }

  Future<void> deleteImage(String imageId) async {
    await _db.customStatement(
      'DELETE FROM product_images WHERE id = ?',
      [imageId],
    );
  }

  Future<void> deleteAllForProduct(String productId) async {
    await _db.customStatement(
      'DELETE FROM product_images WHERE product_id = ?',
      [productId],
    );
  }
}

class ProductImageRecord {
  final String id;
  final String productId;
  final String localPath;
  final String? sourceUrl;
  final int? width;
  final int? height;
  final bool isPrimary;

  const ProductImageRecord({
    required this.id,
    required this.productId,
    required this.localPath,
    this.sourceUrl,
    this.width,
    this.height,
    required this.isPrimary,
  });
}
