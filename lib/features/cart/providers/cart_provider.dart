import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanh_store_app/features/cart/models/cart.dart';

final cartProvider = NotifierProvider<CartNotifier, Map<String, Cart>>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<Map<String, Cart>> {
  @override
  Map<String, Cart> build() {
    // Load cart items when provider is initialized
    _loadCartItems();
    return {};
  }

  Future<void> _savedCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartMap = state.map((key, value) => MapEntry(key, value.toMap()));
    final cartString = jsonEncode(cartMap);
    await prefs.setString("cart", cartString);
  }

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString("cart");
    if (cartString != null) {
      try {
        final Map<String, dynamic> cartMap = jsonDecode(cartString);
        final Map<String, Cart> loadedCart = {};
        cartMap.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            loadedCart[key] = Cart.fromMap(value);
          }
        });
        state = loadedCart;
      } catch (e) {
        // Nếu có lỗi (dữ liệu cũ không hợp lệ), xóa và reset
        await prefs.remove("cart");
        state = {};
      }
    }
  }

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
      _savedCartItems();
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
      _savedCartItems();
    }
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
      _savedCartItems();
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
        _savedCartItems();
      } else {
        // Tuỳ chọn: Nếu số lượng là 1 mà bấm trừ thì xoá luôn sản phẩm
        removeProduct(productId);
        _savedCartItems();
      }
    }
  }

  void removeProduct(String productId) {
    if (state.containsKey(productId)) {
      state.remove(productId);
      state = {...state};
      _savedCartItems();
    }
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.price * cartItem.quantity;
    });
    return totalAmount;
  }

  void clearCart() {
    state = {};
    _savedCartItems();
  }

  Map<String, Cart> get getCartItems => state;
}
