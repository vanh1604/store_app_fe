import 'dart:convert';
import 'package:vanh_store_app/features/products/models/product_variant.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String vendorId;
  final String fullName;
  final double price;
  final int quantity;
  final String category;
  final String subCategory;
  final List<String> images;
  final double averageRating;
  final int totalRatings;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    required this.subCategory,
    required this.images,
    required this.vendorId,
    required this.fullName,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.variants = const [],
  });

  bool get hasVariants => variants.isNotEmpty;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category,
      'subCategory': subCategory,
      'images': images,
      'vendorId': vendorId,
      'fullName': fullName,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'variants': variants.map((v) => v.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity']?.toInt() ?? 0,
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      vendorId: map['vendorId'] ?? '',
      fullName: map['fullName'] ?? '',
      averageRating: map['averageRating']?.toDouble() ?? 0.0,
      totalRatings: map['totalRatings']?.toInt() ?? 0,
      variants: map['variants'] != null
          ? List<ProductVariant>.from(
              (map['variants'] as List).map((v) => ProductVariant.fromMap(v)),
            )
          : [],
    );
  }
}
