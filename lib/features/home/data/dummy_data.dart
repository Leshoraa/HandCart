import 'package:flutter/material.dart';
import 'models/product_model.dart';

class DummyData {
  DummyData._();

  static const List<String> categories = [
    'Semua',
    'Minuman',
    'Makanan',
    'Snack',
    'Kebutuhan Dapur',
    'Peralatan',
  ];

  static const List<Product> sampleProducts = [
    Product(
      id: 'p1',
      name: 'Kopi Susu Gula Aren',
      category: 'Minuman',
      price: 18000,
      description: 'Espresso robusta dengan susu segar dan sirup gula aren murni.',
      icon: Icons.local_cafe_rounded,
      rating: 4.9,
    ),
    Product(
      id: 'p2',
      name: 'Roti Gandum Artisan',
      category: 'Makanan',
      price: 24000,
      description: 'Roti gandum segar panggang harian tinggi serat dan rendah kalori.',
      icon: Icons.bakery_dining_rounded,
      rating: 4.8,
    ),
    Product(
      id: 'p3',
      name: 'Matcha Latte Dingin',
      category: 'Minuman',
      price: 22000,
      description: 'Matcha Uji Jepang asli dipadukan dengan susu oat creamy.',
      icon: Icons.emoji_food_beverage_rounded,
      rating: 4.7,
    ),
    Product(
      id: 'p4',
      name: 'Keripik Tempe Renyah',
      category: 'Snack',
      price: 12000,
      description: 'Keripik tempe olahan tradisional gurih dengan bumbu ketumbar alami.',
      icon: Icons.fastfood_rounded,
      rating: 4.6,
    ),
    Product(
      id: 'p5',
      name: 'Minyak Kelapa Extra Virgin',
      category: 'Kebutuhan Dapur',
      price: 45000,
      description: 'Minyak kelapa murni dingin tanpa bahan kimia pengawet.',
      icon: Icons.soup_kitchen_rounded,
      rating: 4.9,
    ),
    Product(
      id: 'p6',
      name: 'Tas Belanja Ramah Lingkungan',
      category: 'Peralatan',
      price: 15000,
      description: 'Tote bag kanvas tebal reusable untuk belanja harian.',
      icon: Icons.shopping_bag_rounded,
      rating: 4.8,
    ),
  ];
}
