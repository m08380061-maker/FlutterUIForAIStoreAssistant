import '../models/product_model.dart';

class OfflineProductRecognizer {
  static const double defaultConfidenceThreshold = 0.82;
  static const Duration debounceDuration = Duration(seconds: 2);

  static ProductModel? findBestMatch(List<ProductModel> products, String query) {
    if (products.isEmpty) return null;

    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    ProductModel? bestMatch;
    double bestScore = 0;

    for (final product in products) {
      final score = _scoreProduct(product, normalized);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = product;
      }
    }

    if (bestMatch == null || bestScore < defaultConfidenceThreshold) {
      return null;
    }

    return bestMatch;
  }

  static double _scoreProduct(ProductModel product, String normalizedQuery) {
    final barcode = (product.barcode ?? '').trim().toLowerCase();
    final name = (product.name).trim().toLowerCase();
    final category = (product.category).trim().toLowerCase();
    final altName = (product.nameAr ?? '').trim().toLowerCase();

    if (barcode.isNotEmpty && barcode == normalizedQuery) {
      return 1.0;
    }

    if (barcode.isNotEmpty && barcode.contains(normalizedQuery)) {
      return 0.95;
    }

    if (name == normalizedQuery || altName == normalizedQuery) {
      return 0.9;
    }

    if (name.contains(normalizedQuery) || altName.contains(normalizedQuery)) {
      return 0.84;
    }

    if (category.contains(normalizedQuery)) {
      return 0.72;
    }

    return 0.0;
  }
}
