import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/features/products/models/product.dart';

class ProductNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    return [];
  }

  void setProducts(List<Product> products) {
    state = products;
  }
}

final productProvider = NotifierProvider<ProductNotifier, List<Product>>(() {
  return ProductNotifier();
});
