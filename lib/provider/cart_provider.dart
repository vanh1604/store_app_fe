import 'package:flutter_riverpod/legacy.dart';
import 'package:vanh_store_app/models/cart.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, Cart>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<Map<String, Cart>> {
  CartNotifier() : super({});

  void addProductToCart({
    required String productName,
    required int quantity,
    required double price,
    required List<String> image,
    required String category,
    required String vendorId,
    required String productId,
    required String productDescription,
    required int productQuantity,
    required String fullName,
  }) {
    if (state.containsKey(productId)) {
      state = {
        ...state,
        productId: Cart(
          productName: state[productId]!.productName,
          quantity: state[productId]!.quantity++,
          price: state[productId]!.price,
          image: state[productId]!.image,
          category: state[productId]!.category,
          vendorId: state[productId]!.vendorId,
          productId: state[productId]!.productId,
          productDescription: state[productId]!.productDescription,
          productQuantity: state[productId]!.productQuantity,
          fullName: state[productId]!.fullName,
        ),
      };
    } else {
      state = {
        ...state,
        productId: Cart(
          productName: productName,
          quantity: quantity,
          price: price,
          image: image,
          category: category,
          vendorId: vendorId,
          productId: productId,
          productDescription: productDescription,
          productQuantity: productQuantity,
          fullName: fullName,
        ),
      };
    }
    print(state);
  }

  void IncremantQuantity(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity++;
      state = {...state};
    }
  }

  void DecremantQuantity(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity--;
      state = {...state};
    }
  }

  void removeProduct(String productId) {
    if (state.containsKey(productId)) {
      state.remove(productId);
      state = {...state};
    }
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.price * cartItem.quantity;
    });
    return totalAmount;
  }
}
