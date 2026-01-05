import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
    required double productPrice,
    required String category,
    required String image,
    required String buyerId,
    required String vendorId,
    required bool processing,
    required bool delivered,
    required context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("auth-token") ?? "";
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
          "Authorization": "Bearer $token",
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

  Future<List<Order>> loadOrders({required String buyerId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("auth-token") ?? "";
      http.Response res = await http.get(
        Uri.parse("$uri/api/orders/buyers/$buyerId"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token",
        },
      );
      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final List<dynamic> data = responseData['orders'];
        List<Order> orders = data.map((order) => Order.fromMap(order)).toList();
        return orders;
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An error occurred while loading orders: $e');
    }
  }

  Future<void> deleteOrder({required String orderId, required context}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("auth-token") ?? "";
      http.Response res = await http.delete(
        Uri.parse("$uri/api/orders/$orderId"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token",
        },
      );
      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order deleted successfully");
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }
}
