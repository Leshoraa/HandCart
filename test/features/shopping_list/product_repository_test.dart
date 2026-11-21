import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/features/shopping_list/data/models/product_model.dart';
import 'package:handcart/features/shopping_list/data/product_repository.dart';

void main() {
  test('stores a local product image path in the SQLite row map', () {
    const product = Product(
      id: 'product_1',
      storeId: 'store_1',
      name: 'Local product',
      category: 'Other',
      description: 'Photo stored locally',
      icon: Icons.shopping_basket_rounded,
      imagePath: '/app/documents/product_images/product_1.jpg',
    );

    final row = ProductRepository.toDatabaseMap(product);

    expect(row['image_path'], '/app/documents/product_images/product_1.jpg');
    expect(row['quantity'], 1);
    final restoredProduct = ProductRepository.fromDatabaseMap(row);
    expect(
      restoredProduct.imagePath,
      '/app/documents/product_images/product_1.jpg',
    );
  });
}
