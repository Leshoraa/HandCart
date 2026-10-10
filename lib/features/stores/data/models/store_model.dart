import 'package:flutter/material.dart';

class Store {
  final String id;
  final String name;
  final String category;
  final String description;
  final IconData icon;
  final String? imageUrl;
  final String note;
  final DateTime? createdAt;
  final bool? _isPinned;

  const Store({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    this.imageUrl,
    this.note = '',
    this.createdAt,
    bool? isPinned,
  }) : _isPinned = isPinned ?? false;

  bool get isPinned => _isPinned ?? false;

  DateTime get date => createdAt ?? DateTime.now();

  Store copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    IconData? icon,
    String? imageUrl,
    String? note,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
