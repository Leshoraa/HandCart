import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/app.dart';
import 'package:handcart/core/constants/app_strings.dart';

void main() {
  testWidgets('StoreListPage: Date grouping (Today over Yesterday), 3-dots menu actions, and category tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HandCartApp());
    await tester.pumpAndSettle();

    // 1. Initial State: Only 'Yesterday' section exists; 'Shopping Places' title is removed
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
    expect(find.text('Shopping Places'), findsNothing);

    // 2. Category Tab interaction (Capsule morphing test)
    expect(find.text('Supermarket'), findsWidgets);
    await tester.tap(find.text('Supermarket').first);
    await tester.pumpAndSettle();

    // Reset back to All Stores
    await tester.tap(find.text(AppStrings.allStores).first);
    await tester.pumpAndSettle();

    // 3. 3-Dots Action Menu on Card
    final moreButtons = find.byTooltip('Store options');
    expect(moreButtons, findsWidgets);

    // Tap 3-dots menu on first store
    await tester.tap(moreButtons.first);
    await tester.pumpAndSettle();

    // Verify popup menu items
    expect(find.text('Pin Store'), findsOneWidget);
    expect(find.text('Rename / Edit'), findsOneWidget);
    expect(find.text('Delete Store'), findsOneWidget);

    // Tap Pin Store
    await tester.tap(find.text('Pin Store'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.push_pin_rounded), findsWidgets);

    // 4. Add Store: FAB opens AddStoreBottomSheet
    final addFab = find.byType(FloatingActionButton);
    expect(addFab, findsOneWidget);
    await tester.tap(addFab);
    await tester.pumpAndSettle();

    // Verify bottom sheet opened (both FAB and bottom sheet header display 'Add Store')
    expect(find.text(AppStrings.addNewStore), findsNWidgets(2));

    // Enter new store name
    await tester.enterText(
      find.widgetWithText(TextField, AppStrings.storeName),
      'Daily Express Mart',
    );
    await tester.pumpAndSettle();

    // Tap Save Store
    await tester.tap(find.text(AppStrings.saveStore));
    await tester.pumpAndSettle();

    // 5. Verify Date Grouping: 'Today' now appears with the new store, and 'Yesterday' is also present below
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Daily Express Mart'), findsOneWidget);

    // Verify 'Today' comes before 'Yesterday' in vertical layout order
    final todayTop = tester.getTopLeft(find.text('Today')).dy;
    final yesterdayTop = tester.getTopLeft(find.text('Yesterday')).dy;
    expect(todayTop < yesterdayTop, isTrue);
  });
}
