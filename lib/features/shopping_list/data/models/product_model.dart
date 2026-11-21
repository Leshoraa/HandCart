import 'package:flutter/material.dart';

class Product {
  final String id;
  final String storeId;
  final String name;
  final String category;
  final double price;
  final String description;
  final IconData icon;
  final double rating;
  final String? imageUrl;
  final String? imagePath;

  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.category,
    this.price = 0.0,
    required this.description,
    required this.icon,
    this.rating = 4.8,
    this.imageUrl,
    this.imagePath,
  });

  Product copyWith({
    String? id,
    String? storeId,
    String? name,
    String? category,
    double? price,
    String? description,
    IconData? icon,
    double? rating,
    String? imageUrl,
    String? imagePath,
  }) {
    return Product(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
