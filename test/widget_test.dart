import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/app.dart';

void main() {
  testWidgets('HandCart initial smoke test', (WidgetTester tester) async {
    // Set standard mobile screen size for testing
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build HandCartApp and trigger a frame
    await tester.pumpWidget(const HandCartApp());
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('HandCart'), findsOneWidget);

    // Verify search bar is present
    expect(find.byType(TextField), findsOneWidget);

    // Verify 'Semua' category chip is present
    expect(find.text('Semua'), findsOneWidget);

    // Verify buy button is visible
    final firstBuyButton = find.text('Beli').first;
    expect(firstBuyButton, findsOneWidget);

    // Tap first 'Beli' button to add to cart
    await tester.tap(firstBuyButton);
    await tester.pumpAndSettle();

    // Verify SnackBar appeared
    expect(find.byType(SnackBar), findsOneWidget);

    // Verify FloatingActionButton appears with count
    expect(find.text('Keranjang (1)'), findsOneWidget);
  });
}
