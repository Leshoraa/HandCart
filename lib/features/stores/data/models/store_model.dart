import 'package:flutter/material.dart';

class Store {
  final String id;
  final String name;
  final String category;
  final String description;
  final IconData icon;
  final String? imageUrl;
  final String note;

  const Store({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    this.imageUrl,
    this.note = '',
  });

  Store copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    IconData? icon,
    String? imageUrl,
    String? note,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      note: note ?? this.note,
    );
  }
}
