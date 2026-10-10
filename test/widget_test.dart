import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/app.dart';
import 'package:handcart/core/constants/app_strings.dart';

void main() {
  testWidgets('HandCartApp flow: Store selection, product list, and note sheet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HandCartApp());
    await tester.pumpAndSettle();

    // Verify App title and Store section title
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.storesTitle), findsOneWidget);

    // Verify Search bar for stores is present
    expect(find.byType(SearchBar), findsOneWidget);

    // Verify first store 'Grand Fresh Market' is rendered
    final firstStore = find.text('Grand Fresh Market');
    expect(firstStore, findsOneWidget);

    // Tap first store to navigate to StoreProductListPage
    await tester.tap(firstStore);
    await tester.pumpAndSettle();

    // Verify StoreProductListPage is displayed with vertical 1-column list
    expect(find.text('Items to Buy (4)'), findsOneWidget);

    // Verify first product Add button
    final firstAddButton = find.text(AppStrings.addToCart).first;
    expect(firstAddButton, findsOneWidget);

    // Tap Add button to increment product count
    await tester.tap(firstAddButton);
    await tester.pumpAndSettle();

    // Verify Stepper appeared with quantity 1
    expect(find.text('1'), findsOneWidget);

    // Verify bottom total expense bar appears with 1 item planned
    expect(find.text('1 ${AppStrings.singleItemPlanned}'), findsOneWidget);

    // Tap Note Menu button in top right
    final noteButton = find.byIcon(Icons.edit_note_rounded);
    expect(noteButton, findsOneWidget);
    await tester.tap(noteButton);
    await tester.pumpAndSettle();

    // Verify Shopping Notes Sheet opens
    expect(find.text(AppStrings.shoppingNotes), findsOneWidget);
    expect(find.text(AppStrings.saveNotes), findsOneWidget);

    // Save and close notes
    await tester.tap(find.text(AppStrings.saveNotes));
    await tester.pumpAndSettle();

    // Verify returned back to product list
    expect(find.text('Items to Buy (4)'), findsOneWidget);
  });
}
