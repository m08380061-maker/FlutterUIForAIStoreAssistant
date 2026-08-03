import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import 'fingerprint_service.dart';

class ProductIndexService {
  ProductIndexService._();
  static final ProductIndexService instance = ProductIndexService._();

  final _db = AppDatabase.instance;

  Future<void> storeEmbedding({
    required String productId,
    required ProductFingerprint fingerprint,
  }) async {
    await _db.customStatement(
      'INSERT OR REPLACE INTO product_embeddings (id, product_id, embedding_json, image_path, version, created_at) VALUES (?, ?, ?, ?, ?, ?)',
      [
        fingerprint.id,
        productId,
        fingerprint.toJsonString(),
        fingerprint.sourcePath,
        1,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  Future<List<IndexedProduct>> searchByFingerprint(
      ProductFingerprint query, {int limit = 5}) async {
    final rows = await _db.customSelect(
      'SELECT * FROM product_embeddings',
    ).get();

    final results = <IndexedProduct>[];
    for (final row in rows) {
      final embeddingJson =
          row.read<String>('embedding_json');
      final productId = row.read<String>('product_id');
      final imagePath = row.read<String>('image_path');

      try {
        final fp = ProductFingerprint.fromJson(
            jsonDecode(embeddingJson) as Map<String, dynamic>);
        final aHashSim =
            FingerprintService.instance.hammingSimilarity(query.averageHash, fp.averageHash);
        final dHashSim =
            FingerprintService.instance.hammingSimilarity(query.differenceHash, fp.differenceHash);
        final histSim = FingerprintService.instance
            .histogramSimilarity(query.colorHistogram, fp.colorHistogram);
        final score = (aHashSim * 0.35 + dHashSim * 0.35 + histSim * 0.30);
        results.add(IndexedProduct(
          productId: productId,
          imagePath: imagePath,
          score: score,
          fingerprint: fp,
        ));
      } catch (_) {
        continue;
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(limit).toList();
  }

  Future<List<IndexedProduct>> getAllIndexed() async {
    final rows = await _db.customSelect(
      'SELECT * FROM product_embeddings ORDER BY created_at DESC',
    ).get();

    return rows.map((row) {
      final fp = ProductFingerprint.fromJson(
          jsonDecode(row.read<String>('embedding_json')) as Map<String, dynamic>);
      return IndexedProduct(
        productId: row.read<String>('product_id'),
        imagePath: row.read<String>('image_path'),
        score: 1.0,
        fingerprint: fp,
      );
    }).toList();
  }

  Future<void> removeByProductId(String productId) async {
    await _db.customStatement(
      'DELETE FROM product_embeddings WHERE product_id = ?',
      [productId],
    );
  }

  Future<int> getIndexSize() async {
    final rows = await _db.customSelect(
      'SELECT COUNT(*) as count FROM product_embeddings',
    ).get();
    return rows.first.read<int>('count');
  }
}

class IndexedProduct {
  final String productId;
  final String imagePath;
  final double score;
  final ProductFingerprint fingerprint;

  const IndexedProduct({
    required this.productId,
    required this.imagePath,
    required this.score,
    required this.fingerprint,
  });
}
