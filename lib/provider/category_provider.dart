import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/models/category.dart';

class CategoryNotifier extends Notifier<List<Category>> {
  @override
  List<Category> build() {
    return [];
  }

  void setCategories(List<Category> categories) {
    state = categories;
  }
}

final categoryProvider = NotifierProvider<CategoryNotifier, List<Category>>(() {
  return CategoryNotifier();
});
