import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/core/utils/database_icon_data.dart';
import 'package:handcart/features/stores/data/store_dummy_data.dart';

void main() {
  test('restores every seeded store and product icon from database fields', () {
    final icons = [
      ...StoreDummyData.initialStores.map((store) => store.icon),
      ...StoreDummyData.initialProducts.map((product) => product.icon),
      Icons.medication_rounded,
      Icons.local_cafe_rounded,
      Icons.shopping_basket_rounded,
    ];

    for (final expectedIcon in icons) {
      final icon = DatabaseIconData.fromDatabase({
        'icon_code_point': expectedIcon.codePoint,
        'icon_font_family': expectedIcon.fontFamily,
        'icon_font_package': expectedIcon.fontPackage,
      });

      expect(icon, expectedIcon);
    }
  });

  test('rejects unknown database icon values', () {
    expect(
      () => DatabaseIconData.fromDatabase({
        'icon_code_point': -1,
        'icon_font_family': 'Unknown',
        'icon_font_package': null,
      }),
      throwsFormatException,
    );
  });
}
