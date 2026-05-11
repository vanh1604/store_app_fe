import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vanh_store_app/features/orders/models/order.dart';
import 'package:vanh_store_app/core/services/http_response_handler.dart';
import 'package:vanh_store_app/core/services/api_service.dart';

class OrderController {
  Future<String?> uploadOrders({
    required String id,
    required String fullName,
    required String email,
    required String province,
    required String district,
    required String ward,
    required String address,
    required String productId,
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
    String? selectedSize,
    String? variantId,
  }) async {
    try {
      final Order order = Order(
        id: id,
        fullName: fullName,
        email: email,
        province: province,
        district: district,
        ward: ward,
        address: address,
        productId: productId,
        productName: productName,
        quantity: quantity,
        productPrice: productPrice,
        category: category,
        image: image,
        buyerId: buyerId,
        vendorId: vendorId,
        processing: processing,
        delivered: delivered,
        selectedSize: selectedSize,
        variantId: variantId,
      );

      http.Response res = await ApiService.authenticatedRequest(
        method: 'POST',
        endpoint: '/api/createorder',
        body: jsonDecode(order.toJson()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final responseData = jsonDecode(res.body);
        final String? orderId = responseData['order']?['_id'];
        if (orderId == null || orderId.isEmpty) {
          throw Exception("Order created but _id not found in response");
        }

        return orderId;
      } else {
        throw Exception(
          "Failed to create order: ${res.statusCode} - ${res.body}",
        );
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      return null;
    }
  }

  Future<List<Order>> loadOrders({required String buyerId}) async {
    try {
      http.Response res = await ApiService.authenticatedRequest(
        method: 'GET',
        endpoint: '/api/orders/buyers/$buyerId',
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final List<dynamic> data = responseData['orders'];
        List<Order> orders = data.map((order) => Order.fromMap(order)).toList();
        return orders;
      } else {
        throw Exception(
          "Failed to load orders: ${res.statusCode} - ${res.body}",
        );
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An error occurred while loading orders: $e');
    }
  }

  Future<void> deleteOrder({required String orderId, required context}) async {
    try {
      http.Response res = await ApiService.authenticatedRequest(
        method: 'DELETE',
        endpoint: '/api/orders/$orderId',
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

  Future<void> updateOrderProcessing({
    required String orderId,
    required bool processing,
    required context,
  }) async {
    try {
      http.Response res = await ApiService.authenticatedRequest(
        method: 'PATCH',
        endpoint: '/api/orders/$orderId/processing',
        body: {'processing': processing},
      );

      if (res.statusCode != 200) {
        throw Exception(
          "Failed to update order processing: ${res.statusCode} - ${res.body}",
        );
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    required orderId,
  }) async {
    try {
      final requestBody = {
        'amount': amount,
        'currency': currency,
        'orderId': orderId,
      };

      http.Response res = await ApiService.authenticatedRequest(
        method: 'POST',
        endpoint: '/api/orders/payment',
        body: requestBody,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        throw Exception(
          "Failed to create payment intent: ${res.statusCode} - ${res.body}",
        );
      }
    } catch (e) {
      throw Exception('An error occurred while creating payment intent: $e');
    }
  }
}
