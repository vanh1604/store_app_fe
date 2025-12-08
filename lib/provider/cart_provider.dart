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
          quantity: state[productId]!.quantity + 1,
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

  void IncrementQuantity(String productId) {
    if (state.containsKey(productId)) {
      // 1. Lấy item hiện tại
      final currentItem = state[productId]!;

      // 2. Cập nhật state bằng cách tạo object Cart mới với quantity + 1
      state = {
        ...state,
        productId: Cart(
          productName: currentItem.productName,
          quantity: currentItem.quantity + 1, // Tăng số lượng ở đây
          price: currentItem.price,
          image: currentItem.image,
          category: currentItem.category,
          vendorId: currentItem.vendorId,
          productId: currentItem.productId,
          productDescription: currentItem.productDescription,
          productQuantity: currentItem.productQuantity,
          fullName: currentItem.fullName,
        ),
      };
    }
  }

  void DecrementQuantity(String productId) {
    if (state.containsKey(productId)) {
      final currentItem = state[productId]!;

      // Kiểm tra để không giảm xuống dưới 1
      if (currentItem.quantity > 1) {
        state = {
          ...state,
          productId: Cart(
            productName: currentItem.productName,
            quantity: currentItem.quantity - 1, // Giảm số lượng ở đây
            price: currentItem.price,
            image: currentItem.image,
            category: currentItem.category,
            vendorId: currentItem.vendorId,
            productId: currentItem.productId,
            productDescription: currentItem.productDescription,
            productQuantity: currentItem.productQuantity,
            fullName: currentItem.fullName,
          ),
        };
      } else {
        // Tuỳ chọn: Nếu số lượng là 1 mà bấm trừ thì xoá luôn sản phẩm
        removeProduct(productId);
      }
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

  Map<String, Cart> get getCartItems => state;
}
