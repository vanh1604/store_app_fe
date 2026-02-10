import 'dart:convert';

class Order {
  final String id;
  final String fullName;
  final String email;
  final String state;
  final String city;
  final String locality;
  final String productName;
  final int quantity;
  final double productPrice;
  final String category;
  final String image;
  final String buyerId;
  final String vendorId;
  final bool processing;
  final bool delivered;

  Order({
    required this.id,
    required this.fullName,
    required this.email,
    required this.state,
    required this.city,
    required this.locality,
    required this.productName,
    required this.quantity,
    required this.productPrice,
    required this.category,
    required this.image,
    required this.buyerId,
    required this.vendorId,
    required this.processing,
    required this.delivered,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'fullName': fullName,
    'email': email,
    'state': state,
    'city': city,
    'locality': locality,
    'productName': productName,
    'quantity': quantity,
    'productPrice': productPrice,
    'category': category,
    'image': image,
    'buyerId': buyerId,
    'vendorId': vendorId,
    'processing': processing,
    'delivered': delivered,
  };
  String toJson() => json.encode(toMap());

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['_id'],
      fullName: map['fullName'],
      email: map['email'],
      state: map['state'],
      city: map['city'],
      locality: map['locality'],
      productName: map['productName'],
      quantity: map['quantity'],
      productPrice: (map['productPrice'] as num).toDouble(),
      category: map['category'],
      image: map['image'],
      buyerId: map['buyerId'],
      vendorId: map['vendorId'],
      processing: map['processing'],
      delivered: map['delivered'],
    );
  }
}
