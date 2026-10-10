import 'package:flutter/material.dart';
import 'models/product_model.dart';

class DummyData {
  DummyData._();

  static const List<String> categories = [
    'All',
    'Beverages',
    'Food',
    'Snacks',
    'Pantry',
    'Accessories',
  ];

  static const List<Product> sampleProducts = [
    Product(
      id: 'p1',
      name: 'Palm Sugar Iced Latte',
      category: 'Beverages',
      price: 4.50,
      description: 'Robusta espresso with fresh milk and organic palm sugar syrup.',
      icon: Icons.local_cafe_rounded,
      rating: 4.9,
    ),
    Product(
      id: 'p2',
      name: 'Artisan Sourdough Bread',
      category: 'Food',
      price: 6.00,
      description: 'Freshly baked artisan whole wheat sourdough bread, rich in fiber.',
      icon: Icons.bakery_dining_rounded,
      rating: 4.8,
    ),
    Product(
      id: 'p3',
      name: 'Iced Matcha Latte',
      category: 'Beverages',
      price: 5.50,
      description: 'Authentic Japanese Uji matcha blended with creamy oat milk.',
      icon: Icons.emoji_food_beverage_rounded,
      rating: 4.7,
    ),
    Product(
      id: 'p4',
      name: 'Crispy Tempeh Chips',
      category: 'Snacks',
      price: 3.00,
      description: 'Traditional savory tempeh crisps seasoned with aromatic coriander.',
      icon: Icons.fastfood_rounded,
      rating: 4.6,
    ),
    Product(
      id: 'p5',
      name: 'Extra Virgin Coconut Oil',
      category: 'Pantry',
      price: 12.00,
      description: 'Cold-pressed pure organic coconut oil without chemical preservatives.',
      icon: Icons.soup_kitchen_rounded,
      rating: 4.9,
    ),
    Product(
      id: 'p6',
      name: 'Eco-Friendly Canvas Tote',
      category: 'Accessories',
      price: 8.00,
      description: 'Heavy-duty reusable canvas tote bag for daily shopping.',
      icon: Icons.shopping_bag_rounded,
      rating: 4.8,
    ),
  ];
}
