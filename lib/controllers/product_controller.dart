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

  Future<List<Product>> loadProductByCategory(String category) async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/getproductByCategory/$category"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        List<Product> products = data
            .map((product) => Product.fromMap(product))
            .toList();
        return products;
      } else {
        throw Exception("Failed to load products by category");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception(
        'An error occurred while loading products by category: $e',
      );
    }
  }

  Future<Product> loadProductById(String id) async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/getproductById/$id"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        return Product.fromMap(data);
      } else {
        throw Exception("Failed to load products by id");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An error occurred while loading products by id: $e');
    }
  }

  Future<List<Product>> relatedProducts(String productId) async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/relatedproducts/$productId"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        List<dynamic> data = responseData["relatedProducts"] ?? [];
        List<Product> relatedProducts = data
            .map((product) => Product.fromMap(product))
            .toList();
        return relatedProducts;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception('An error occurred while loading products: $e');
    }
  }

  Future<List<Product>> topRatedProducts() async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/topratedproducts"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        List<dynamic> data = responseData["topRatedProducts"] ?? [];
        List<Product> relatedProducts = data
            .map((product) => Product.fromMap(product))
            .toList();
        return relatedProducts;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception('An error occurred while loading products: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final url = Uri.parse(
        "$uri/api/products/search",
      ).replace(queryParameters: {'query': query});

      http.Response res = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        List<Product> products = data
            .map((product) => Product.fromMap(product))
            .toList();
        return products;
      } else {
        throw Exception("Failed to search products");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An error occurred while searching products: $e');
    }
  }

  Future<List<Product>> getProductsBySubcategory(String subcategory) async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/products/subcategory/$subcategory"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        List<dynamic> data = responseData["products"] ?? [];
        List<Product> relatedProducts = data
            .map((product) => Product.fromMap(product))
            .toList();
        return relatedProducts;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception('An error occurred while loading products: $e');
    }
  }

  Future<List<Product>> getProductsByVendorId({
    required String vendorId,
  }) async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/products/vendor/$vendorId"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        List<dynamic> data = responseData["products"] ?? [];
        List<Product> allProducts = data
            .map((product) => Product.fromMap(product))
            .toList();
        return allProducts;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception('An error occurred while loading products: $e');
    }
  }
}
