import 'dart:convert';

class Cart {
  final String productName;
  int quantity;
  final double price;
  final List<String> image;
  final String category;
  final String vendorId;
  final String productId;
  final String productDescription;
  final int productQuantity;
  final String fullName;

  Cart({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.image,
    required this.category,
    required this.vendorId,
    required this.productId,
    required this.productDescription,
    required this.productQuantity,
    required this.fullName,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'image': image,
      'category': category,
      'vendorId': vendorId,
      'productId': productId,
      'productDescription': productDescription,
      'productQuantity': productQuantity,
      'fullName': fullName,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'],
      image: List<String>.from(map['image']),
      category: map['category'],
      vendorId: map['vendorId'],
      productId: map['productId'],
      productDescription: map['productDescription'],
      productQuantity: map['productQuantity'],
      fullName: map['fullName'],
    );
  }
  String toJson() => json.encode(toMap());
}
