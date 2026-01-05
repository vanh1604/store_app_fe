import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanh_store_app/models/favorite.dart';

final favoriteProvider =
    NotifierProvider<FavoriteNotifier, Map<String, Favorite>>(() {
  return FavoriteNotifier();
});

class FavoriteNotifier extends Notifier<Map<String, Favorite>> {
  @override
  Map<String, Favorite> build() {
    // Load favorites when provider is initialized
    _loadFavorites();
    return {};
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteString = prefs.getString("favorites");
    if (favoriteString != null) {
      try {
        final Map<String, dynamic> favoriteMap = jsonDecode(favoriteString);
        final Map<String, Favorite> loadedFavorites = {};
        favoriteMap.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            loadedFavorites[key] = Favorite.fromMap(value);
          }
        });
        state = loadedFavorites;
      } catch (e) {
        // Nếu có lỗi (dữ liệu cũ không hợp lệ), xóa và reset
        await prefs.remove("favorites");
        state = {};
      }
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteMap = state.map((key, value) => MapEntry(key, value.toMap()));
    final favoriteString = jsonEncode(favoriteMap);
    await prefs.setString("favorites", favoriteString);
  }

  void addProductToFavorite({
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
    state[productId] = Favorite(
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
    );
    state = {...state};
    _saveFavorites();
  }

  void removeFavoriteItem(String productId) {
    if (state.containsKey(productId)) {
      state.remove(productId);
      state = {...state};
      _saveFavorites();
    }
  }

  Map<String, Favorite> get getFavorite => state;
}
