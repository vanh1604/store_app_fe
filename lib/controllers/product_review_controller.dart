import 'package:http/http.dart' as http;
import 'package:vanh_store_app/global_variables.dart';
import 'package:vanh_store_app/models/product_review.dart';
import 'package:vanh_store_app/services/manage_http_response.dart';

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
}
