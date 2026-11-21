import 'package:flutter/material.dart';

class DatabaseIconData {
  DatabaseIconData._();

  static const List<IconData> _supportedIcons = [
    Icons.local_grocery_store_rounded,
    Icons.bakery_dining_rounded,
    Icons.eco_rounded,
    Icons.storefront_rounded,
    Icons.local_cafe_rounded,
    Icons.medication_rounded,
    Icons.local_drink_rounded,
    Icons.apple_rounded,
    Icons.egg_rounded,
    Icons.soup_kitchen_rounded,
    Icons.fastfood_rounded,
    Icons.shopping_bag_rounded,
    Icons.shopping_basket_rounded,
  ];

  static IconData fromDatabase(Map<String, Object?> row) {
    final codePoint = row['icon_code_point'] as int;
    final fontFamily = row['icon_font_family'] as String?;
    final fontPackage = row['icon_font_package'] as String?;

    for (final icon in _supportedIcons) {
      if (icon.codePoint == codePoint &&
          icon.fontFamily == fontFamily &&
          icon.fontPackage == fontPackage) {
        return icon;
      }
    }

    throw FormatException('Unsupported stored icon code point: $codePoint.');
  }
}
