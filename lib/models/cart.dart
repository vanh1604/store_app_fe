class Cart {
  final String productName;
  final int quantity;
  final double price;
  final List image;
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
}
