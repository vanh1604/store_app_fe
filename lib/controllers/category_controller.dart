import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vanh_store_app/global_variables.dart';
import 'package:vanh_store_app/models/category.dart';

class CategoryController {
  Future<List<Category>> loadCategories() async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/getcategory"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        print(res.body);
        Map<String, dynamic> responseData = jsonDecode(res.body);
        List<dynamic> data = responseData['category'] ?? [];
        List<Category> categories = data
            .map((category) => Category.fromJson(category))
            .toList();
        print(categories);
        return categories;
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An error occurred while loading categories: $e');
    }
  }
}
