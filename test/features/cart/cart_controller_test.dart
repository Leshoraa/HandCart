import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/features/cart/state/cart_controller.dart';
import 'package:handcart/features/home/data/models/product_model.dart';

void main() {
  group('CartController Business Logic Tests', () {
    late CartController cartController;

    const sampleProductA = Product(
      id: 'test_1',
      name: 'Coffee',
      category: 'Beverages',
      price: 10.0,
      description: 'Test coffee',
      icon: Icons.local_cafe,
    );

    const sampleProductB = Product(
      id: 'test_2',
      name: 'Bread',
      category: 'Food',
      price: 20.0,
      description: 'Test bread',
      icon: Icons.bakery_dining,
    );

    setUp(() {
      cartController = CartController();
    });

    tearDown(() {
      cartController.dispose();
    });

    test('Initial state: cart is empty with zero count and total', () {
      expect(cartController.isEmpty, isTrue);
      expect(cartController.totalCount, equals(0));
      expect(cartController.subtotal, equals(0.0));
      expect(cartController.tax, equals(0.0));
      expect(cartController.totalPrice, equals(0.0));
    });

    test('addItem: adds new item and increments item count correctly', () {
      cartController.addItem(sampleProductA);

      expect(cartController.isEmpty, isFalse);
      expect(cartController.totalCount, equals(1));
      expect(cartController.getQuantity(sampleProductA.id), equals(1));
      expect(cartController.subtotal, equals(10.0));
      expect(cartController.tax, closeTo(1.10, 0.001));
      expect(cartController.totalPrice, closeTo(11.10, 0.001));
    });

    test('addItem: adds multiple quantities of same product', () {
      cartController.addItem(sampleProductA);
      cartController.addItem(sampleProductA);

      expect(cartController.totalCount, equals(2));
      expect(cartController.getQuantity(sampleProductA.id), equals(2));
      expect(cartController.subtotal, equals(20.0));
      expect(cartController.tax, closeTo(2.20, 0.001));
      expect(cartController.totalPrice, closeTo(22.20, 0.001));
    });

    test('removeSingleItem: decrements quantity and removes when zero', () {
      cartController.addItem(sampleProductA);
      cartController.addItem(sampleProductA);
      expect(cartController.getQuantity(sampleProductA.id), equals(2));

      cartController.removeSingleItem(sampleProductA.id);
      expect(cartController.getQuantity(sampleProductA.id), equals(1));

      cartController.removeSingleItem(sampleProductA.id);
      expect(cartController.getQuantity(sampleProductA.id), equals(0));
      expect(cartController.containsProduct(sampleProductA.id), isFalse);
      expect(cartController.isEmpty, isTrue);
    });

    test('deleteItem: completely removes specific item regardless of quantity', () {
      cartController.addItem(sampleProductA);
      cartController.addItem(sampleProductA);
      cartController.addItem(sampleProductB);

      expect(cartController.items.length, equals(2));
      expect(cartController.totalCount, equals(3));

      cartController.deleteItem(sampleProductA.id);
      expect(cartController.items.length, equals(1));
      expect(cartController.containsProduct(sampleProductA.id), isFalse);
      expect(cartController.getQuantity(sampleProductB.id), equals(1));
    });

    test('clear: empties all items from the cart', () {
      cartController.addItem(sampleProductA);
      cartController.addItem(sampleProductB);
      expect(cartController.items.length, equals(2));

      cartController.clear();
      expect(cartController.isEmpty, isTrue);
      expect(cartController.totalCount, equals(0));
      expect(cartController.subtotal, equals(0.0));
      expect(cartController.totalPrice, equals(0.0));
    });
  });
}
