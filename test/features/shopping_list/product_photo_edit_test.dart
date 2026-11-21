import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handcart/features/shopping_list/data/models/presentation/pages/add_item_page.dart';
import 'package:handcart/features/shopping_list/data/models/presentation/pages/store_product_list_page.dart';
import 'package:handcart/features/shopping_list/services/product_image_service.dart';
import 'package:handcart/features/shopping_list/state/shopping_planner_scope.dart';

import '../../support/in_memory_shopping_repositories.dart';

void main() {
  testWidgets('Add Item navigates to a full page and saves selected quantity', (
    tester,
  ) async {
    final controller = createInMemoryPlannerController();
    addTearDown(controller.dispose);
    await controller.initialize();
    final store = controller.stores.first;

    await tester.pumpWidget(
      ShoppingPlannerScope(
        controller: controller,
        child: MaterialApp(
          home: StoreProductListPage(
            store: store,
            imageService: ProductImageService(
              retrieveLostImage: () async => null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();
    expect(find.byType(AddItemPage), findsOneWidget);
    expect(find.text('Add an item for ${store.name}'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('add_item_save')));
    await tester.tap(find.byKey(const ValueKey('add_item_save')));
    await tester.pumpAndSettle();
    expect(find.text('Item name is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('add_item_name')),
      'Page item',
    );
    await tester.enterText(find.byKey(const ValueKey('add_item_price')), '-3');
    await tester.enterText(
      find.byKey(const ValueKey('add_item_quantity')),
      '0',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('add_item_save')));
    await tester.tap(find.byKey(const ValueKey('add_item_save')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid non-negative price.'), findsOneWidget);
    expect(find.text('Quantity must be at least 1.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('add_item_price')),
      '7.25',
    );
    await tester.enterText(
      find.byKey(const ValueKey('add_item_quantity')),
      '3',
    );
    await tester.tap(find.byKey(const ValueKey('add_item_save')));
    await tester.pumpAndSettle();

    final addedProduct = controller.products.singleWhere(
      (product) => product.name == 'Page item',
    );
    expect(addedProduct.storeId, store.id);
    expect(addedProduct.category, store.category);
    expect(addedProduct.price, 7.25);
    expect(controller.getProductQuantity(addedProduct.id), 3);
    expect(find.byType(AddItemPage), findsNothing);
  });

  testWidgets('product form validates name and non-negative price', (
    tester,
  ) async {
    final controller = createInMemoryPlannerController();
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      ShoppingPlannerScope(
        controller: controller,
        child: MaterialApp(
          home: StoreProductListPage(
            store: controller.stores.first,
            imageService: ProductImageService(
              retrieveLostImage: () async => null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final initialProductCount = controller.products.length;
    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save Item'));
    await tester.tap(find.text('Save Item'));
    await tester.pumpAndSettle();
    expect(find.text('Item name is required.'), findsOneWidget);

    final nameField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Item Name',
    );
    final priceField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Price (optional)',
    );
    await tester.enterText(nameField, 'Test item');
    await tester.enterText(priceField, '-1');
    await tester.ensureVisible(find.text('Save Item'));
    await tester.tap(find.text('Save Item'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid non-negative price.'), findsOneWidget);
    expect(controller.products, hasLength(initialProductCount));

    await tester.enterText(priceField, '12.50');
    await tester.ensureVisible(find.text('Save Item'));
    await tester.tap(find.text('Save Item'));
    await tester.pumpAndSettle();

    expect(controller.products, hasLength(initialProductCount + 1));
    expect(
      controller.products.any(
        (product) => product.name == 'Test item' && product.price == 12.5,
      ),
      isTrue,
    );
  });

  testWidgets('product menu deletes an item after confirmation', (
    tester,
  ) async {
    final controller = createInMemoryPlannerController();
    addTearDown(controller.dispose);
    await controller.initialize();
    final product = controller.products.first;

    await tester.pumpWidget(
      ShoppingPlannerScope(
        controller: controller,
        child: MaterialApp(
          home: StoreProductListPage(store: controller.stores.first),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Product options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Item'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(controller.products.any((item) => item.id == product.id), isFalse);
  });

  testWidgets('camera cancellation preserves an existing product photo path', (
    tester,
  ) async {
    final controller = createInMemoryPlannerController();
    addTearDown(controller.dispose);
    await controller.initialize();

    final product = controller.products.first;
    const previousImagePath = 'existing-product-photo.jpg';
    await controller.updateProduct(
      product.copyWith(imagePath: previousImagePath),
    );

    final imageService = ProductImageService(
      captureImage: () async => null,
      retrieveLostImage: () async => null,
    );

    await tester.pumpWidget(
      ShoppingPlannerScope(
        controller: controller,
        child: MaterialApp(
          home: StoreProductListPage(
            store: controller.stores.first,
            imageService: imageService,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Product options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retake photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(
      controller.products.firstWhere((item) => item.id == product.id).imagePath,
      previousImagePath,
    );
  });

  testWidgets(
    'AddItemPage renders 4:3 camera preview above item name and captures/removes photo',
    (tester) async {
      final controller = createInMemoryPlannerController();
      addTearDown(controller.dispose);
      await controller.initialize();
      final store = controller.stores.first;

      final tempDir = await Directory.systemTemp.createTemp('handcart_test_');
      addTearDown(() async {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      });
      final fakeImageFile = File('${tempDir.path}/fake_camera.jpg');
      await fakeImageFile.writeAsBytes([0xFF, 0xD8, 0xFF]);

      var captureCallCount = 0;
      final imageService = ProductImageService(
        captureImage: () async {
          captureCallCount++;
          return XFile(fakeImageFile.path);
        },
        retrieveLostImage: () async => null,
        documentsDirectory: () async => tempDir,
      );

      await tester.pumpWidget(
        ShoppingPlannerScope(
          controller: controller,
          child: MaterialApp(
            home: AddItemPage(
              storeId: store.id,
              storeName: store.name,
              storeCategory: store.category,
              imageService: imageService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify camera preview widget is present
      final cameraPreview = find.byKey(
        const ValueKey('add_item_camera_preview'),
      );
      expect(cameraPreview, findsOneWidget);
      expect(find.text('Camera Preview'), findsOneWidget);
      expect(find.text('4:3'), findsOneWidget);

      // Verify camera preview is positioned strictly above item name field
      final previewRect = tester.getRect(cameraPreview);
      final nameRect = tester.getRect(
        find.byKey(const ValueKey('add_item_name')),
      );
      expect(previewRect.bottom, lessThan(nameRect.top));

      // Verify exact 4:3 aspect ratio
      expect(previewRect.width / previewRect.height, closeTo(4.0 / 3.0, 0.05));

      // Tap to capture photo
      await tester.tap(cameraPreview);
      await tester.pumpAndSettle();
      expect(captureCallCount, 1);

      // Verify photo preview is now showing with retake and remove buttons
      expect(
        find.byKey(const ValueKey('add_item_retake_photo')),
        findsOneWidget,
      );
      final removeBtn = find.byKey(const ValueKey('add_item_remove_photo'));
      expect(removeBtn, findsOneWidget);

      // Tap remove photo button to clear the image
      await tester.tap(removeBtn);
      await tester.pumpAndSettle();

      // Should return back to placeholder state
      expect(find.text('Camera Preview'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('add_item_retake_photo')),
        findsNothing,
      );
    },
  );
}
