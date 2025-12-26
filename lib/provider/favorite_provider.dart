import 'package:flutter_riverpod/legacy.dart';
import 'package:vanh_store_app/models/favorite.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotfier, Map<String, Favorite>>(
      (ref) => FavoriteNotfier(),
    );

class FavoriteNotfier extends StateNotifier<Map<String, Favorite>> {
  FavoriteNotfier() : super({});

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
  }

  void removeFavoriteItem(String productId) {
    if (state.containsKey(productId)) {
      state.remove(productId);
      state = {...state};
    }
  }

  Map<String, Favorite> get getFavorite => state;
}
