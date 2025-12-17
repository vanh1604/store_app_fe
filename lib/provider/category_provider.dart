import 'package:flutter_riverpod/legacy.dart';
import 'package:vanh_store_app/models/category.dart';

class CategoryProvider extends StateNotifier<List<Category>> {
  CategoryProvider() : super([]);
  void setCategories(List<Category> categories) {
    state = categories;
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryProvider, List<Category>>(
      (ref) => CategoryProvider(),
    );
