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

  String _cartKey(String productId, String? variantId) {
    return variantId != null && variantId.isNotEmpty
        ? '${productId}_$variantId'
        : productId;
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
    String? selectedSize,
    String? variantId,
  }) {
    final key = _cartKey(productId, variantId);
    if (state.containsKey(key)) {
      final existing = state[key]!;
      state = {
        ...state,
        key: Cart(
          productName: existing.productName,
          quantity: existing.quantity + 1,
          price: existing.price,
          image: existing.image,
          category: existing.category,
          vendorId: existing.vendorId,
          productId: existing.productId,
          productDescription: existing.productDescription,
          productQuantity: existing.productQuantity,
          fullName: existing.fullName,
          selectedSize: existing.selectedSize,
          variantId: existing.variantId,
        ),
      };
      _savedCartItems();
    } else {
      state = {
        ...state,
        key: Cart(
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
          selectedSize: selectedSize,
          variantId: variantId,
        ),
      };
      _savedCartItems();
    }
  }

  void IncrementQuantity(String cartKey) {
    if (state.containsKey(cartKey)) {
      final currentItem = state[cartKey]!;
      state = {
        ...state,
        cartKey: Cart(
          productName: currentItem.productName,
          quantity: currentItem.quantity + 1,
          price: currentItem.price,
          image: currentItem.image,
          category: currentItem.category,
          vendorId: currentItem.vendorId,
          productId: currentItem.productId,
          productDescription: currentItem.productDescription,
          productQuantity: currentItem.productQuantity,
          fullName: currentItem.fullName,
          selectedSize: currentItem.selectedSize,
          variantId: currentItem.variantId,
        ),
      };
      _savedCartItems();
    }
  }

  void DecrementQuantity(String cartKey) {
    if (state.containsKey(cartKey)) {
      final currentItem = state[cartKey]!;
      if (currentItem.quantity > 1) {
        state = {
          ...state,
          cartKey: Cart(
            productName: currentItem.productName,
            quantity: currentItem.quantity - 1,
            price: currentItem.price,
            image: currentItem.image,
            category: currentItem.category,
            vendorId: currentItem.vendorId,
            productId: currentItem.productId,
            productDescription: currentItem.productDescription,
            productQuantity: currentItem.productQuantity,
            fullName: currentItem.fullName,
            selectedSize: currentItem.selectedSize,
            variantId: currentItem.variantId,
          ),
        };
        _savedCartItems();
      } else {
        removeProduct(cartKey);
      }
    }
  }

  void removeProduct(String cartKey) {
    if (state.containsKey(cartKey)) {
      final newState = Map<String, Cart>.from(state);
      newState.remove(cartKey);
      state = newState;
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
