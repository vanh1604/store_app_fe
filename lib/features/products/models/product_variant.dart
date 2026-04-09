import 'dart:convert';

class ProductVariant {
  final String id;
  final String size;
  final String? color;
  final double price;
  final int quantity;

  ProductVariant({
    required this.id,
    required this.size,
    this.color,
    required this.price,
    required this.quantity,
  });

  /// Label hiển thị: "M / Đỏ" hoặc chỉ "M" nếu không có màu
  String get label => color != null && color!.isNotEmpty ? '$size / $color' : size;

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) '_id': id,
      'size': size,
      if (color != null && color!.isNotEmpty) 'color': color,
      'price': price,
      'quantity': quantity,
    };
  }

  String toJson() => json.encode(toMap());

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['_id'] ?? '',
      size: map['size'] ?? '',
      color: map['color'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }
}
