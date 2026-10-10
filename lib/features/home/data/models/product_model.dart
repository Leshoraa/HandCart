import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final IconData icon;
  final double rating;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.icon,
    this.rating = 4.8,
    this.imageUrl,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    IconData? icon,
    double? rating,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
