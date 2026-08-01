import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

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

  static Future<ProductModel?> matchImageFile(List<ProductModel> products, String imagePath) async {
    final targetSignature = await _loadSignatureFromFile(imagePath);
    if (targetSignature == null) return null;
    return _findBestSignatureMatch(products, targetSignature);
  }

  static Future<ProductModel?> matchCameraImage(List<ProductModel> products, CameraImage image) async {
    final targetSignature = _buildSignatureFromCameraImage(image);
    if (targetSignature == null) return null;
    return _findBestSignatureMatch(products, targetSignature);
  }

  static Future<ProductModel?> _findBestSignatureMatch(
    List<ProductModel> products,
    List<int> targetSignature,
  ) async {
    if (products.isEmpty) return null;

    ProductModel? bestMatch;
    double bestScore = 0;

    for (final product in products) {
      final imageUrl = product.imageUrl?.trim();
      if (imageUrl == null || imageUrl.isEmpty) continue;
      final imageFile = File(imageUrl);
      if (!await imageFile.exists()) continue;
      final signature = await _loadSignatureFromFile(imageUrl);
      if (signature == null) continue;

      final score = _compareSignatures(signature, targetSignature);
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

  static Future<List<int>?> _loadSignatureFromFile(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      return _buildSignatureFromBytes(bytes);
    } catch (_) {
      return null;
    }
  }

  static List<int>? _buildSignatureFromBytes(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      final gray = img.grayscale(decoded);
      final resized = img.copyResize(gray, width: 8, height: 8);
      final values = <int>[];
      final threshold = _averagePixelValue(resized);
      for (var y = 0; y < resized.height; y++) {
        for (var x = 0; x < resized.width; x++) {
          final pixel = resized.getPixel(x, y);
          final luminance = (pixel.r + pixel.g + pixel.b) ~/ 3;
          values.add(luminance > threshold ? 1 : 0);
        }
      }
      return values;
    } catch (_) {
      return null;
    }
  }

  static List<int>? _buildSignatureFromCameraImage(CameraImage image) {
    try {
      final plane = image.planes.first;
      final bytes = plane.bytes;
      final stride = plane.bytesPerRow;
      final values = <int>[];
      for (var y = 0; y < 8; y++) {
        for (var x = 0; x < 8; x++) {
          final sourceY = (y * image.height / 8).round();
          final sourceX = (x * image.width / 8).round();
          final index = (sourceY * stride) + sourceX;
          final value = index < bytes.length ? bytes[index] : 0;
          values.add(value);
        }
      }
      final average = values.reduce((a, b) => a + b) / values.length;
      return values.map((value) => value > average ? 1 : 0).toList();
    } catch (_) {
      return null;
    }
  }

  static int _averagePixelValue(img.Image image) {
    var sum = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        sum += (pixel.r + pixel.g + pixel.b) ~/ 3;
      }
    }
    return sum ~/ (image.width * image.height);
  }

  static double _compareSignatures(List<int> left, List<int> right) {
    if (left.length != right.length) return 0;
    var matches = 0;
    for (var index = 0; index < left.length; index++) {
      if (left[index] == right[index]) matches++;
    }
    return matches / left.length;
  }

  static double _scoreProduct(ProductModel product, String normalizedQuery) {
    final barcode = (product.barcode ?? '').trim().toLowerCase();
    final name = product.name.trim().toLowerCase();
    final category = product.category.trim().toLowerCase();
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
