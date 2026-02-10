import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanh_store_app/core/config/global_variables.dart';

class ApiService {
  // Make authenticated API call with automatic token refresh
  static Future<http.Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('auth-token');

    if (token == null) {
      throw Exception('No auth token found');
    }

    // Prepare headers
    final headers = <String, String>{
      "Content-Type": "application/json;charset=UTF-8",
      "Authorization": "Bearer $token",
      ...?additionalHeaders,
    };

    // Make initial request
    http.Response response = await _makeRequest(
      method: method,
      url: '$uri$endpoint',
      body: body,
      headers: headers,
    );

    // If token expired (401), refresh and retry
    if (response.statusCode == 401) {
      debugPrint('Token expired, attempting to refresh...');
      String? newToken = await _refreshAccessToken();

      if (newToken != null) {
        // Update authorization header with new token
        headers["Authorization"] = "Bearer $newToken";

        // Retry the request
        response = await _makeRequest(
          method: method,
          url: '$uri$endpoint',
          body: body,
          headers: headers,
        );
      } else {
        throw Exception('Failed to refresh token');
      }
    }

    return response;
  }

  // Internal method to make HTTP request based on method
  static Future<http.Response> _makeRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    required Map<String, String> headers,
  }) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(Uri.parse(url), headers: headers);
      case 'POST':
        return await http.post(
          Uri.parse(url),
          body: body != null ? jsonEncode(body) : null,
          headers: headers,
        );
      case 'PUT':
        return await http.put(
          Uri.parse(url),
          body: body != null ? jsonEncode(body) : null,
          headers: headers,
        );
      case 'DELETE':
        return await http.delete(Uri.parse(url), headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Refresh access token using refresh token
  static Future<String?> _refreshAccessToken() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? refreshToken = preferences.getString('refresh-token');

      if (refreshToken == null) {
        debugPrint('No refresh token found');
        return null;
      }

      http.Response res = await http.post(
        Uri.parse('$uri/api/refresh-token'),
        body: jsonEncode({'refreshToken': refreshToken}),
        headers: <String, String>{
          "Content-Type": "application/json;charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        final responseBody = jsonDecode(res.body);
        String newAccessToken = responseBody['accessToken'];
        String newRefreshToken = responseBody['refreshToken'];

        // Save new tokens
        await preferences.setString('auth-token', newAccessToken);
        await preferences.setString('refresh-token', newRefreshToken);

        debugPrint('Tokens refreshed successfully');
        return newAccessToken;
      } else {
        debugPrint('Failed to refresh token: ${res.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return null;
    }
  }
}
