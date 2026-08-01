import 'package:flutter_test/flutter_test.dart';
import 'package:FlutterUIForAIStoreAssistant/shared/models/product_model.dart';
import 'package:FlutterUIForAIStoreAssistant/shared/models/sale_model.dart';
import 'package:FlutterUIForAIStoreAssistant/shared/models/debt_model.dart';
import 'package:FlutterUIForAIStoreAssistant/shared/models/user_model.dart';

/// Regression tests protecting the core domain model calculations that
/// underpin the entire app — profit margins, stock status, debt status,
/// and sale totals. These are pure-Dart tests with no database dependency.
void main() {
  group('ProductModel', () {
    final baseProduct = ProductModel(
      id: 'p1',
      name: 'Rice (5kg)',
      category: 'Grains',
      purchasePrice: 2100,
      sellingPrice: 2500,
      quantity: 20,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('profit is sellingPrice minus purchasePrice', () {
      expect(baseProduct.profit, 400);
    });

    test('profitMargin is profit / purchasePrice * 100', () {
      expect(baseProduct.profitMargin, closeTo(19.047, 0.01));
    });

    test('profitMargin is 0 when purchasePrice is 0', () {
      final freeProduct = ProductModel(
        id: 'p2',
        name: 'Sample',
        category: 'Misc',
        purchasePrice: 0,
        sellingPrice: 10,
        quantity: 5,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      expect(freeProduct.profitMargin, 0);
    });

    test('isLowStock is true when quantity is 1..10', () {
      final lowStock = baseProduct.copyWith(quantity: 5);
      expect(lowStock.isLowStock, isTrue);
    });

    test('isLowStock is false when quantity is 0', () {
      final outOfStock = baseProduct.copyWith(quantity: 0);
      expect(outOfStock.isLowStock, isFalse);
    });

    test('isOutOfStock is true when quantity is 0', () {
      final outOfStock = baseProduct.copyWith(quantity: 0);
      expect(outOfStock.isOutOfStock, isTrue);
    });

    test('isOutOfStock is false when quantity is positive', () {
      expect(baseProduct.isOutOfStock, isFalse);
    });

    test('stockStatus returns correct string for each state', () {
      expect(baseProduct.copyWith(quantity: 0).stockStatus, 'Out of Stock');
      expect(baseProduct.copyWith(quantity: 5).stockStatus, 'Low Stock');
      expect(baseProduct.copyWith(quantity: 50).stockStatus, 'In Stock');
    });

    test('toJson and fromJson round-trip preserves all fields', () {
      final json = baseProduct.toJson();
      final restored = ProductModel.fromJson(json);
      expect(restored.id, baseProduct.id);
      expect(restored.name, baseProduct.name);
      expect(restored.category, baseProduct.category);
      expect(restored.purchasePrice, baseProduct.purchasePrice);
      expect(restored.sellingPrice, baseProduct.sellingPrice);
      expect(restored.quantity, baseProduct.quantity);
      expect(restored.barcode, baseProduct.barcode);
      expect(restored.isActive, baseProduct.isActive);
    });
  });

  group('SaleModel', () {
    final items = [
      SaleItemModel(
        productId: 'p1',
        productName: 'Rice (5kg)',
        quantity: 2,
        unitPrice: 2500,
        totalPrice: 5000,
      ),
      SaleItemModel(
        productId: 'p2',
        productName: 'Cooking Oil (1L)',
        quantity: 1,
        unitPrice: 1200,
        totalPrice: 1200,
      ),
    ];

    test('total equals subtotal minus discount', () {
      final sale = SaleModel(
        id: 's1',
        items: items,
        subtotal: 6200,
        discount: 200,
        total: 6000,
        workerId: 'w1',
        createdAt: DateTime(2024, 6, 15),
      );
      expect(sale.total, 6000);
      expect(sale.subtotal - sale.discount, equals(sale.total));
    });

    test('total equals subtotal when discount is 0', () {
      final sale = SaleModel(
        id: 's2',
        items: items,
        subtotal: 6200,
        total: 6200,
        workerId: 'w1',
        createdAt: DateTime(2024, 6, 15),
      );
      expect(sale.total, equals(sale.subtotal));
      expect(sale.discount, 0);
    });

    test('paymentMethod defaults to cash', () {
      final sale = SaleModel(
        id: 's3',
        items: items,
        subtotal: 100,
        total: 100,
        workerId: 'w1',
        createdAt: DateTime(2024),
      );
      expect(sale.paymentMethod, 'cash');
    });

    test('toJson serializes all fields including nested items', () {
      final sale = SaleModel(
        id: 's4',
        items: items,
        subtotal: 6200,
        discount: 200,
        total: 6000,
        workerId: 'w1',
        customerId: 'c1',
        customerName: 'Ahmed',
        createdAt: DateTime(2024, 6, 15),
        paymentMethod: 'card',
      );
      final json = sale.toJson();
      expect(json['id'], 's4');
      expect(json['subtotal'], 6200);
      expect(json['discount'], 200);
      expect(json['total'], 6000);
      expect(json['paymentMethod'], 'card');
      expect((json['items'] as List).length, 2);
    });
  });

  group('DebtModel', () {
    test('status is unpaid when no payments', () {
      final debt = DebtModel(
        id: 'd1',
        customerId: 'c1',
        customerName: 'Ahmed',
        originalAmount: 5000,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(debt.status, DebtStatus.unpaid);
      expect(debt.totalPaid, 0);
      expect(debt.remaining, 5000);
    });

    test('status is partiallyPaid when some payments exist', () {
      final debt = DebtModel(
        id: 'd2',
        customerId: 'c1',
        customerName: 'Ahmed',
        originalAmount: 5000,
        payments: [
          DebtPayment(id: 'pay1', amount: 2000, paidAt: DateTime(2024, 1, 5)),
        ],
        createdAt: DateTime(2024, 1, 1),
      );
      expect(debt.status, DebtStatus.partiallyPaid);
      expect(debt.totalPaid, 2000);
      expect(debt.remaining, 3000);
    });

    test('status is paid when payments cover the full amount', () {
      final debt = DebtModel(
        id: 'd3',
        customerId: 'c1',
        customerName: 'Ahmed',
        originalAmount: 5000,
        payments: [
          DebtPayment(id: 'pay1', amount: 5000, paidAt: DateTime(2024, 1, 5)),
        ],
        createdAt: DateTime(2024, 1, 1),
      );
      expect(debt.status, DebtStatus.paid);
      expect(debt.remaining, 0);
    });

    test('isOverdue is true when dueDate is past and not fully paid', () {
      final debt = DebtModel(
        id: 'd4',
        customerId: 'c1',
        customerName: 'Ahmed',
        originalAmount: 5000,
        dueDate: DateTime(2020, 1, 1),
        createdAt: DateTime(2019, 12, 1),
      );
      expect(debt.isOverdue, isTrue);
    });

    test('isOverdue is false when debt is paid even if dueDate passed', () {
      final debt = DebtModel(
        id: 'd5',
        customerId: 'c1',
        customerName: 'Ahmed',
        originalAmount: 5000,
        dueDate: DateTime(2020, 1, 1),
        payments: [
          DebtPayment(id: 'pay1', amount: 5000, paidAt: DateTime(2019, 12, 15)),
        ],
        createdAt: DateTime(2019, 12, 1),
      );
      expect(debt.isOverdue, isFalse);
    });

    test('isOverdue is false when no dueDate is set', () {
      final debt = DebtModel(
        id: 'd6',
        customerId: 'c1',
        customerName: 'Ahmed',
        originalAmount: 5000,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(debt.isOverdue, isFalse);
    });
  });

  group('UserModel', () {
    test('isMerchant / isWorker / isCustomer check role correctly', () {
      final merchant = UserModel(
        id: 'u1', fullName: 'Owner', email: 'o@x.com',
        phone: '123', role: 'merchant', createdAt: DateTime(2024),
      );
      final worker = UserModel(
        id: 'u2', fullName: 'Cashier', email: 'c@x.com',
        phone: '456', role: 'worker', createdAt: DateTime(2024),
      );
      final customer = UserModel(
        id: 'u3', fullName: 'Buyer', email: 'b@x.com',
        phone: '789', role: 'customer', createdAt: DateTime(2024),
      );

      expect(merchant.isMerchant, isTrue);
      expect(merchant.isWorker, isFalse);
      expect(worker.isWorker, isTrue);
      expect(worker.isMerchant, isFalse);
      expect(customer.isCustomer, isTrue);
      expect(customer.isMerchant, isFalse);
    });

    test('initials extracts first letters of first two words', () {
      final user = UserModel(
        id: 'u1', fullName: 'Ahmed Ali', email: '', phone: '',
        role: 'merchant', createdAt: DateTime(2024),
      );
      expect(user.initials, 'AA');
    });

    test('initials handles single-name input', () {
      final user = UserModel(
        id: 'u1', fullName: 'Mohammed', email: '', phone: '',
        role: 'merchant', createdAt: DateTime(2024),
      );
      expect(user.initials, 'M');
    });
  });
}
