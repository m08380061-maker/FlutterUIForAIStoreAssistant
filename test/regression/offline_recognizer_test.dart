import 'package:flutter_test/flutter_test.dart';
import 'package:FlutterUIForAIStoreAssistant/shared/models/product_model.dart';
import 'package:FlutterUIForAIStoreAssistant/shared/services/offline_product_recognizer.dart';

/// Regression tests for the OfflineProductRecognizer scoring logic.
void main() {
  final products = [
    ProductModel(
      id: 'p1', name: 'Rice (5kg)', nameAr: 'أرز', category: 'Grains',
      purchasePrice: 2100, sellingPrice: 2500, quantity: 20,
      barcode: '6281234567890', createdAt: DateTime(2024), updatedAt: DateTime(2024),
    ),
    ProductModel(
      id: 'p2', name: 'Cooking Oil (1L)', category: 'Oils',
      purchasePrice: 1000, sellingPrice: 1200, quantity: 8,
      barcode: '6281234567891', createdAt: DateTime(2024), updatedAt: DateTime(2024),
    ),
  ];

  group('OfflineProductRecognizer.findBestMatch', () {
    test('exact barcode match returns product with score 1.0', () {
      final match = OfflineProductRecognizer.findBestMatch(products, '6281234567890');
      expect(match?.id, 'p1');
    });

    test('whitespace-padded barcode is normalized and matched', () {
      final match = OfflineProductRecognizer.findBestMatch(products, ' 6281234567890 ');
      expect(match?.id, 'p1');
    });

    test('partial barcode match returns product (contains match)', () {
      final match = OfflineProductRecognizer.findBestMatch(products, '628123456');
      expect(match?.id, 'p1');
    });

    test('exact name match returns product', () {
      final match = OfflineProductRecognizer.findBestMatch(products, 'rice (5kg)');
      expect(match?.id, 'p1');
    });

    test('partial name match returns product', () {
      final match = OfflineProductRecognizer.findBestMatch(products, 'rice');
      expect(match?.id, 'p1');
    });

    test('Arabic name match returns product', () {
      final match = OfflineProductRecognizer.findBestMatch(products, 'أرز');
      expect(match?.id, 'p1');
    });

    test('category-only match is below threshold and returns null', () {
      final match = OfflineProductRecognizer.findBestMatch(products, 'grains');
      expect(match, isNull);
    });

    test('unmatched query returns null', () {
      final match = OfflineProductRecognizer.findBestMatch(products, 'xyz999');
      expect(match, isNull);
    });

    test('empty query returns null', () {
      final match = OfflineProductRecognizer.findBestMatch(products, '');
      expect(match, isNull);
    });

    test('empty product list returns null', () {
      final match = OfflineProductRecognizer.findBestMatch([], '6281234567890');
      expect(match, isNull);
    });
  });
}
