import 'package:flutter_test/flutter_test.dart';
import 'package:FlutterUIForAIStoreAssistant/shared/models/product_model.dart';
import 'package:FlutterUIForAIStoreAssistant/shared/services/offline_product_recognizer.dart';

void main() {
  group('OfflineProductRecognizer', () {
    test('matches products by normalized barcode', () {
      final products = [
        ProductModel(
          id: 'p1',
          name: 'Rice',
          category: 'Grains',
          purchasePrice: 10,
          sellingPrice: 12,
          quantity: 5,
          barcode: '6281234567890',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ];

      final match = OfflineProductRecognizer.findBestMatch(products, ' 6281234567890 ');

      expect(match?.id, 'p1');
      expect(match?.name, 'Rice');
    });

    test('returns null for unmatched barcode', () {
      final products = [
        ProductModel(
          id: 'p1',
          name: 'Rice',
          category: 'Grains',
          purchasePrice: 10,
          sellingPrice: 12,
          quantity: 5,
          barcode: '6281234567890',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ];

      final match = OfflineProductRecognizer.findBestMatch(products, '9999999999999');

      expect(match, isNull);
    });
  });
}
