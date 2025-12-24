import 'dart:convert';

class ProductReview {
  final String id;
  final String buyerId;
  final String productId;
  final String fullName;
  final String email;
  final String review;
  final double rating;

  ProductReview({
    required this.id,
    required this.buyerId,
    required this.productId,
    required this.fullName,
    required this.email,
    required this.review,
    required this.rating,
  });

  factory ProductReview.fromMap(Map<String, dynamic> json) {
    return ProductReview(
      id: json['_id'],
      buyerId: json['buyerId'],
      productId: json['productId'],
      fullName: json['fullName'],
      email: json['email'],
      review: json['review'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'productId': productId,
      'fullName': fullName,
      'email': email,
      'review': review,
      'rating': rating,
    };
  }

  String toJson() => json.encode(toMap());
  factory ProductReview.fromJson(String source) =>
      ProductReview.fromMap(json.decode(source));
}
