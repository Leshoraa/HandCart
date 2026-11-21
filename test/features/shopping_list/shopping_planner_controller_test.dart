import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/features/shopping_list/data/models/product_model.dart';
import 'package:handcart/features/shopping_list/state/shopping_planner_controller.dart';
import 'package:handcart/features/stores/data/models/store_model.dart';
import 'package:handcart/features/stores/data/store_dummy_data.dart';

import '../../support/in_memory_shopping_repositories.dart';

void main() {
  group('ShoppingPlannerController Tests', () {
    late ShoppingPlannerController controller;

    setUp(() async {
      controller = createInMemoryPlannerController();
      await controller.initialize();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initializes with default stores and products at quantity 1', () {
      expect(
        controller.stores.length,
        equals(StoreDummyData.initialStores.length),
      );
      expect(
        controller.products.length,
        equals(StoreDummyData.initialProducts.length),
      );
      expect(
        controller.getTotalPlannedCount(),
        equals(controller.products.length),
      );
      expect(controller.getTotalPlannedExpense() > 0, isTrue);
      for (final product in controller.products) {
        expect(controller.getProductQuantity(product.id), equals(1));
      }
    });

    test('increment and decrement quantity through the repository', () async {
      final store = controller.stores.first;
      final product = controller.getProductsForStore(store.id).first;
      final initialStoreCount = controller.getStoreItemCount(store.id);

      expect(controller.getProductQuantity(product.id), equals(1));

      await controller.incrementQuantity(product);
      expect(controller.getProductQuantity(product.id), equals(2));
      expect(
        controller.getStoreItemCount(store.id),
        equals(initialStoreCount + 1),
      );

      await controller.decrementQuantity(product.id);
      expect(controller.getProductQuantity(product.id), equals(1));

      await controller.decrementQuantity(product.id);
      expect(controller.getProductQuantity(product.id), equals(0));
      expect(
        controller.getStoreItemCount(store.id),
        equals(initialStoreCount - 1),
      );
    });

    test('updateStoreNote updates the store memo', () async {
      final store = controller.stores.first;
      const newNote = 'Remember coupon code: SAVE10';

      await controller.updateStoreNote(store.id, newNote);
      expect(controller.getStoreNote(store.id), equals(newNote));
    });

    test('addStore inserts a new store after repository success', () async {
      final initialCount = controller.stores.length;
      const customStore = Store(
        id: 'store_custom',
        name: 'Neighborhood Bodega',
        category: 'Mart',
        description: 'Corner shop',
        icon: Icons.store_rounded,
        note: 'Buy sparkling soda',
      );

      await controller.addStore(customStore);
      expect(controller.stores.length, equals(initialCount + 1));
      expect(controller.stores.first.id, equals('store_custom'));
      expect(
        controller.getStoreNote('store_custom'),
        equals('Buy sparkling soda'),
      );
    });

    test('addProduct starts at quantity 1', () async {
      const newProduct = Product(
        id: 'prod_custom',
        storeId: 'store_1',
        name: 'Avocado',
        category: 'Produce',
        price: 2.50,
        description: 'Ripe Hass avocado',
        icon: Icons.eco,
      );

      final initialStoreProducts = controller
          .getProductsForStore('store_1')
          .length;
      await controller.addProduct(newProduct);
      final updatedProducts = controller.getProductsForStore('store_1');

      expect(updatedProducts.length, equals(initialStoreProducts + 1));
      expect(
        updatedProducts.any((product) => product.id == 'prod_custom'),
        isTrue,
      );
      expect(controller.getProductQuantity('prod_custom'), equals(1));
    });

    test('clearStoreItems clears quantities only for that store', () async {
      final store1 = controller.stores[0];
      final store2 = controller.stores[1];
      final initialStore2Count = controller.getStoreItemCount(store2.id);

      expect(controller.getStoreItemCount(store1.id) > 0, isTrue);

      await controller.clearStoreItems(store1.id);
      expect(controller.getStoreItemCount(store1.id), equals(0));
      expect(
        controller.getStoreItemCount(store2.id),
        equals(initialStore2Count),
      );
    });

    test('updateStore modifies store information and notes', () async {
      final store = controller.stores.first;
      final updated = store.copyWith(
        name: 'Grand Fresh Supermarket Renamed',
        category: 'Megamart',
        description: 'Updated store description',
        note: 'New memo note',
      );

      await controller.updateStore(updated);
      final found = controller.stores.firstWhere((item) => item.id == store.id);
      expect(found.name, equals('Grand Fresh Supermarket Renamed'));
      expect(found.category, equals('Megamart'));
      expect(found.description, equals('Updated store description'));
      expect(controller.getStoreNote(store.id), equals('New memo note'));
    });

    test('togglePinStore updates the pin status', () async {
      final store = controller.stores.first;
      expect(store.isPinned, isFalse);

      await controller.togglePinStore(store.id);
      expect(
        controller.stores.firstWhere((item) => item.id == store.id).isPinned,
        isTrue,
      );

      await controller.togglePinStore(store.id);
      expect(
        controller.stores.firstWhere((item) => item.id == store.id).isPinned,
        isFalse,
      );
    });

    test('deleteStore removes store, note, products, and quantities', () async {
      final store = controller.stores.first;
      final initialStoreCount = controller.stores.length;
      final product = controller.getProductsForStore(store.id).first;

      await controller.incrementQuantity(product);
      expect(controller.getProductQuantity(product.id), equals(2));

      await controller.deleteStore(store.id);

      expect(controller.stores.length, equals(initialStoreCount - 1));
      expect(controller.stores.any((item) => item.id == store.id), isFalse);
      expect(() => controller.getStoreNote(store.id), throwsStateError);
      expect(controller.getProductsForStore(store.id), isEmpty);
      expect(controller.getProductQuantity(product.id), equals(0));
    });
  });
}
