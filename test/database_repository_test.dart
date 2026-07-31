import 'package:flutter_test/flutter_test.dart';
import 'package:ai_store_assistant/core/database/app_database.dart';
import 'package:ai_store_assistant/shared/repositories/product_repository.dart';
import 'package:ai_store_assistant/shared/repositories/repository_exceptions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProductRepository repository;

  setUp(() async {
    await AppDatabase.instance.reset();
    repository = ProductRepository();
  });

  test('creates and loads products from the local database', () async {
    final created = await repository.createProduct(
      name: 'Rice',
      category: 'Grains',
      purchasePrice: 2000,
      sellingPrice: 2500,
      quantity: 10,
      barcode: '111',
    );

    final products = await repository.getAllProducts();

    expect(created.name, 'Rice');
    expect(products, hasLength(1));
    expect(products.first.barcode, '111');
  });

  test('rejects duplicate barcodes', () async {
    await repository.createProduct(
      name: 'Oil',
      category: 'Cooking',
      purchasePrice: 1000,
      sellingPrice: 1200,
      quantity: 5,
      barcode: '222',
    );

    expect(
      () async => repository.createProduct(
        name: 'More Oil',
        category: 'Cooking',
        purchasePrice: 1000,
        sellingPrice: 1200,
        quantity: 5,
        barcode: '222',
      ),
      throwsA(isA<ValidationException>()),
    );
  });
}
