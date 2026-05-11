import 'dart:convert';

class Order {
  final String id;
  final String fullName;
  final String email;
  final String province;
  final String district;
  final String ward;
  final String address;
  final String productId;

  final String productName;
  final int quantity;
  final double productPrice;
  final String category;
  final String image;
  final String buyerId;
  final String vendorId;
  final bool processing;
  final bool delivered;
  final DateTime? orderedAt;
  final String? selectedSize;
  final String? variantId;

  Order({
    required this.id,
    required this.fullName,
    required this.email,
    required this.province,
    required this.district,
    required this.ward,
    required this.address,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.productPrice,
    required this.category,
    required this.image,
    required this.buyerId,
    required this.vendorId,
    required this.processing,
    required this.delivered,
    this.orderedAt,
    this.selectedSize,
    this.variantId,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'fullName': fullName,
    'email': email,
    'province': province,
    'district': district,
    'ward': ward,
    'address': address,
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'productPrice': productPrice,
    'category': category,
    'image': image,
    'buyerId': buyerId,
    'vendorId': vendorId,
    'processing': processing,
    'delivered': delivered,
    if (selectedSize != null) 'selectedSize': selectedSize,
    if (variantId != null) 'variantId': variantId,
  };
  String toJson() => json.encode(toMap());

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['_id'] ?? map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      ward: map['ward'] ?? '',
      address: map['address'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      image: map['image'] ?? '',
      buyerId: map['buyerId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      processing: map['processing'] ?? false,
      delivered: map['delivered'] ?? false,
      orderedAt: map['orderedAt'] != null ? DateTime.tryParse(map['orderedAt'].toString()) : null,
      selectedSize: map['selectedSize'],
      variantId: map['variantId'],
    );
  }
}
