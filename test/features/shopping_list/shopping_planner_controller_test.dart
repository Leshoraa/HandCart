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

    test('Initializes with default stores and auto 1 quantities for products', () {
      expect(controller.stores.isNotEmpty, isTrue);
      expect(controller.products.isNotEmpty, isTrue);
      expect(controller.getTotalPlannedCount(), equals(controller.products.length));
      expect(controller.getTotalPlannedExpense() > 0, isTrue);
    });

    test('incrementQuantity and decrementQuantity updates item count and expenses', () {
      final store = controller.stores.first;
      final product = controller.getProductsForStore(store.id).first;
      final initialStoreCount = controller.getStoreItemCount(store.id);

      expect(controller.getProductQuantity(product.id), equals(1));

      controller.incrementQuantity(product);
      expect(controller.getProductQuantity(product.id), equals(2));
      expect(controller.getStoreItemCount(store.id), equals(initialStoreCount + 1));

      controller.decrementQuantity(product.id);
      expect(controller.getProductQuantity(product.id), equals(1));

      controller.decrementQuantity(product.id);
      expect(controller.getProductQuantity(product.id), equals(0));
      expect(controller.getStoreItemCount(store.id), equals(initialStoreCount - 1));
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
      final initialStore2Count = controller.getStoreItemCount(store2.id);

      expect(controller.getStoreItemCount(store1.id) > 0, isTrue);

      controller.clearStoreItems(store1.id);
      expect(controller.getStoreItemCount(store1.id), equals(0));
      expect(controller.getStoreItemCount(store2.id), equals(initialStore2Count));
    });

    test('updateStore modifies store information and notes', () {
      final store = controller.stores.first;
      final updated = store.copyWith(
        name: 'Grand Fresh Supermarket Renamed',
        category: 'Megamart',
        description: 'Updated store description',
        note: 'New memo note',
      );

      controller.updateStore(updated);
      final found = controller.stores.firstWhere((s) => s.id == store.id);
      expect(found.name, equals('Grand Fresh Supermarket Renamed'));
      expect(found.category, equals('Megamart'));
      expect(found.description, equals('Updated store description'));
      expect(controller.getStoreNote(store.id), equals('New memo note'));
    });

    test('togglePinStore toggles isPinned boolean flag', () {
      final store = controller.stores.first;
      expect(store.isPinned, isFalse);

      controller.togglePinStore(store.id);
      expect(controller.stores.firstWhere((s) => s.id == store.id).isPinned, isTrue);

      controller.togglePinStore(store.id);
      expect(controller.stores.firstWhere((s) => s.id == store.id).isPinned, isFalse);
    });

    test('deleteStore removes store, its notes, and its products', () {
      final store = controller.stores.first;
      final initialStoreCount = controller.stores.length;
      final product = controller.getProductsForStore(store.id).first;

      controller.incrementQuantity(product);
      expect(controller.getProductQuantity(product.id), equals(2));

      controller.deleteStore(store.id);

      expect(controller.stores.length, equals(initialStoreCount - 1));
      expect(controller.stores.any((s) => s.id == store.id), isFalse);
      expect(controller.getStoreNote(store.id), isEmpty);
      expect(controller.getProductsForStore(store.id), isEmpty);
      expect(controller.getProductQuantity(product.id), equals(0));
    });
  });
}
