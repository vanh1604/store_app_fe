import 'dart:convert';

import 'package:vanh_store_app/core/config/global_variables.dart';
import 'package:vanh_store_app/features/categories/models/subcategory.dart';
import 'package:http/http.dart' as http;

class SubcategoryController {
  Future<List<Subcategory>> getSubCategoriesByCategoryName(
    String categoryName,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$uri/api/category/$categoryName/subcategories"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        List<dynamic> data = responseData['subCategories'] ?? [];

        if (data.isNotEmpty) {
          return data
              .map((subcategory) => Subcategory.fromJson(subcategory))
              .toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        print('Subcategory not found');
        return [];
      } else {
        throw Exception("Failed to load subcategories");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
