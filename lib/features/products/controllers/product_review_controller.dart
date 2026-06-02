import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vanh_store_app/core/config/global_variables.dart';
import 'package:vanh_store_app/features/products/models/product_review.dart';
import 'package:vanh_store_app/core/services/http_response_handler.dart';

class ProductReviewController {
  uploadReview({
    required String productId,
    required String buyerId,
    required double rating,
    required String review,
    required String fullName,
    required String email,
    required context,
  }) async {
    try {
      final ProductReview productReview = ProductReview(
        id: '',
        buyerId: buyerId,
        productId: productId,
        fullName: fullName,
        email: email,
        review: review,
        rating: rating,
      );
      final http.Response res = await http.post(
        Uri.parse('$uri/api/product-review'),
        body: productReview.toJson(),
        headers: <String, String>{
          "Content-Type": "application/json;charset=UTF-8",
        },
      );
      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Review uploaded successfully");
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<List<ProductReview>> getReviewsByProductId(String productId) async {
    try {
      final http.Response res = await http.get(
        Uri.parse('$uri/api/product-review?productId=$productId'),
        headers: <String, String>{
          "Content-Type": "application/json;charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        if (body.containsKey('productReview') && body['productReview'] != null) {
          final List<dynamic> data = body['productReview'];
          return data.map((review) => ProductReview.fromMap(review)).toList();
        }
        return [];
      } else {
        throw Exception("Failed to fetch reviews: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }
}
