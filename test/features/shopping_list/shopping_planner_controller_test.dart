import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/features/shopping_list/data/models/product_model.dart';
import 'package:handcart/features/shopping_list/state/shopping_planner_controller.dart';
import 'package:handcart/features/stores/data/models/store_model.dart';

void main() {
  group('ShoppingPlannerController Tests', () {
    late ShoppingPlannerController controller;

    setUp(() {
      controller = ShoppingPlannerController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initializes with default stores and empty quantities', () {
      expect(controller.stores.isNotEmpty, isTrue);
      expect(controller.products.isNotEmpty, isTrue);
      expect(controller.getTotalPlannedCount(), equals(0));
      expect(controller.getTotalPlannedExpense(), equals(0.0));
    });

    test('incrementQuantity and decrementQuantity updates item count and expenses', () {
      final store = controller.stores.first;
      final product = controller.getProductsForStore(store.id).first;

      expect(controller.getProductQuantity(product.id), equals(0));

      controller.incrementQuantity(product);
      expect(controller.getProductQuantity(product.id), equals(1));
      expect(controller.getStoreItemCount(store.id), equals(1));
      expect(controller.getStoreTotalPrice(store.id), equals(product.price));
      expect(controller.getTotalPlannedExpense(), equals(product.price));

      controller.incrementQuantity(product);
      expect(controller.getProductQuantity(product.id), equals(2));
      expect(controller.getStoreTotalPrice(store.id), equals(product.price * 2));

      controller.decrementQuantity(product.id);
      expect(controller.getProductQuantity(product.id), equals(1));

      controller.decrementQuantity(product.id);
      expect(controller.getProductQuantity(product.id), equals(0));
      expect(controller.getStoreItemCount(store.id), equals(0));
      expect(controller.getStoreTotalPrice(store.id), equals(0.0));
    });

    test('updateStoreNote updates note memo for specific store', () {
      final store = controller.stores.first;
      const newNote = 'Remember coupon code: SAVE10';

      controller.updateStoreNote(store.id, newNote);
      expect(controller.getStoreNote(store.id), equals(newNote));
    });

    test('addStore inserts a new store to the list', () {
      final initialCount = controller.stores.length;
      const customStore = Store(
        id: 'store_custom',
        name: 'Neighborhood Bodega',
        category: 'Mart',
        description: 'Corner shop',
        icon: Icons.store_rounded,
        note: 'Buy sparkling soda',
      );

      controller.addStore(customStore);
      expect(controller.stores.length, equals(initialCount + 1));
      expect(controller.stores.first.id, equals('store_custom'));
      expect(controller.getStoreNote('store_custom'), equals('Buy sparkling soda'));
    });

    test('addProduct adds a new product to store', () {
      const newProduct = Product(
        id: 'prod_custom',
        storeId: 'store_1',
        name: 'Avocado',
        category: 'Produce',
        price: 2.50,
        description: 'Ripe Hass avocado',
        icon: Icons.eco,
      );

      final initialStoreProducts = controller.getProductsForStore('store_1').length;
      controller.addProduct(newProduct);
      final updatedProducts = controller.getProductsForStore('store_1');

      expect(updatedProducts.length, equals(initialStoreProducts + 1));
      expect(updatedProducts.any((p) => p.id == 'prod_custom'), isTrue);
    });

    test('clearStoreItems clears quantities only for that store', () {
      final store1 = controller.stores[0];
      final store2 = controller.stores[1];

      final prod1 = controller.getProductsForStore(store1.id).first;
      final prod2 = controller.getProductsForStore(store2.id).first;

      controller.incrementQuantity(prod1);
      controller.incrementQuantity(prod2);

      expect(controller.getStoreItemCount(store1.id), equals(1));
      expect(controller.getStoreItemCount(store2.id), equals(1));

      controller.clearStoreItems(store1.id);
      expect(controller.getStoreItemCount(store1.id), equals(0));
      expect(controller.getStoreItemCount(store2.id), equals(1));
    });
  });
}
