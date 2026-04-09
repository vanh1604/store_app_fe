class ChatProduct {
  final String id;
  final String name;
  final double price;
  final List<String> images;
  final String category;
  final double averageRating;

  const ChatProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.category,
    required this.averageRating,
  });

  factory ChatProduct.fromMap(Map<String, dynamic> map) {
    return ChatProduct(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
