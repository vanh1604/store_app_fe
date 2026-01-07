import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/models/subcategory.dart';

class SubcategoryNotifier extends Notifier<List<Subcategory>> {
  @override
  List<Subcategory> build() {
    return [];
  }

  void setSubcategories(List<Subcategory> subcategories) {
    state = subcategories;
  }
}

final subcategoryProvider =
    NotifierProvider<SubcategoryNotifier, List<Subcategory>>(() {
  return SubcategoryNotifier();
});
