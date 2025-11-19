import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vanh_store_app/global_variables.dart';
import 'package:vanh_store_app/models/product.dart';

class ProductController {
  Future<List<Product>> loadPopularProducts() async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/getproductpopular"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        print(data);
        List<Product> products = data
            .map((product) => Product.fromMap(product))
            .toList();
        return products;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An error occurred while loading products: $e');
    }
  }
}
