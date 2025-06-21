import 'package:flutter/material.dart'; // tambahkan ini untuk Colors

class Product {
  final int? id;
  final String name;
  final String? description;
  final int? categoryId;
  final int quantity;
  final double? price;
  final String? sku;
  final String? location;
  final String? supplier;
  final int? minStock;
  final int? maxStock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    this.description,
    this.categoryId,
    required this.quantity,
    this.price,
    this.sku,
    this.location,
    this.supplier,
    this.minStock,
    this.maxStock,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      categoryId: json['category_id'],
      quantity: json['quantity'] ?? 0,
      price: json['price']?.toDouble(),
      sku: json['sku'],
      location: json['location'],
      supplier: json['supplier'],
      minStock: json['min_stock'],
      maxStock: json['max_stock'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category_id': categoryId,
      'quantity': quantity,
      'price': price,
      'sku': sku,
      'location': location,
      'supplier': supplier,
      'min_stock': minStock,
      'max_stock': maxStock,
    };
  }

  // Helper method untuk copy with changes
  Product copyWith({
    int? id,
    String? name,
    String? description,
    int? categoryId,
    int? quantity,
    double? price,
    String? sku,
    String? location,
    String? supplier,
    int? minStock,
    int? maxStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      location: location ?? this.location,
      supplier: supplier ?? this.supplier,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper untuk status stock
  String get stockStatus {
    if (minStock != null && quantity <= minStock!) {
      return 'Low Stock';
    } else if (maxStock != null && quantity >= maxStock!) {
      return 'Overstock';
    }
    return 'Normal';
  }

  // Helper untuk stock color
  Color get stockStatusColor {
    switch (stockStatus) {
      case 'Low Stock':
        return Colors.red;
      case 'Overstock':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
