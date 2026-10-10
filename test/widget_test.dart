import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/app.dart';
import 'package:handcart/core/constants/app_strings.dart';

void main() {
  testWidgets('HandCartApp renders catalog and adds item to cart',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HandCartApp());
    await tester.pumpAndSettle();

    // Verify AppBar displays app title
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Verify SearchBar is present
    expect(find.byType(SearchBar), findsOneWidget);

    // Verify category filter chips are present
    expect(find.text(AppStrings.allCategories), findsOneWidget);

    // Verify product card and Add button are rendered
    final firstAddButton = find.text(AppStrings.addToCart).first;
    expect(firstAddButton, findsOneWidget);

    // Tap Add button to add item into cart
    await tester.tap(firstAddButton);
    await tester.pumpAndSettle();

    // Verify floating SnackBar notification appears
    expect(find.byType(SnackBar), findsOneWidget);

    // Verify Cart floating bottom bar appears with item count
    expect(find.text('${AppStrings.cartPrefix} (1)'), findsOneWidget);
  });
}
