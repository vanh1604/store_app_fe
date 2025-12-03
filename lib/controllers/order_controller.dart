import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vanh_store_app/global_variables.dart';
import 'package:vanh_store_app/models/order.dart';
import 'package:vanh_store_app/services/manage_http_response.dart';

class OrderController {
  uploadOrders({
    required String id,
    required String fullName,
    required String email,
    required String state,
    required String city,
    required String locality,
    required String productName,
    required int quantity,
    required int productPrice,
    required String category,
    required String image,
    required String buyerId,
    required String vendorId,
    required bool processing,
    required bool delivered,
    required context,
  }) async {
    try {
      final Order order = Order(
        id: id,
        fullName: fullName,
        email: email,
        state: state,
        city: city,
        locality: locality,
        productName: productName,
        quantity: quantity,
        productPrice: productPrice,
        category: category,
        image: image,
        buyerId: buyerId,
        vendorId: vendorId,
        processing: processing,
        delivered: delivered,
      );
      http.Response res = await http.post(
        Uri.parse("$uri/api/createorder"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: order.toJson(),
      );
      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order created successfully");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
