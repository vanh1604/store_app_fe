import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanh_store_app/global_variables.dart';
import 'package:vanh_store_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:vanh_store_app/provider/user_provider.dart';
import 'package:vanh_store_app/services/manage_http_response.dart';
import 'package:vanh_store_app/services/api_service.dart';
import 'package:vanh_store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:vanh_store_app/views/screens/authentication_screens/otp_screen.dart';
import 'package:vanh_store_app/views/screens/main_screen.dart';

final providerContainer = ProviderContainer();

class AuthController {
  Future<void> signUpUser({
    required BuildContext context,
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      User user = User(
        id: "",
        fullName: fullName,
        state: "",
        city: "",
        locality: "",
        email: email,
        password: password,
        token: '',
      );
      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          "Content-Type": "application/json;charset=UTF-8",
        },
      );
      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OtpScreen(email: email)),
          );
          showSnackBar(context, 'Account has been Created for you');
        },
      );
    } catch (e) {
      debugPrint('Đã xảy ra lỗi khi đăng ký: $e');
      showSnackBar(context, 'Đã xảy ra lỗi: $e');
    }
  }

  Future<void> signInUser({
    required BuildContext context,
    required String email,
    required String password,
    required WidgetRef ref,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          "Content-Type": "application/json;charset=UTF-8",
        },
      );
      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();

          // Backend now returns accessToken and refreshToken
          final responseBody = jsonDecode(res.body);
          String accessToken = responseBody['accessToken'];
          String refreshToken = responseBody['refreshToken'];

          // Save both tokens
          await preferences.setString('auth-token', accessToken);
          await preferences.setString('refresh-token', refreshToken);

          // Save user data
          final userJsonMap = responseBody['user'];
          userJsonMap['token'] = accessToken;
          final userJson = jsonEncode(userJsonMap);

          ref.read(userProvider.notifier).setUser(userJson);
          await preferences.setString('user', userJson);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            ((route) => false),
          );
          showSnackBar(context, 'Login successfully');
        },
      );
    } catch (e) {
      debugPrint('Đã xảy ra lỗi khi đăng nhập: $e');
      showSnackBar(context, 'Đã xảy ra lỗi: $e');
    }
  }

  // Refresh Access Token using Refresh Token
  Future<String?> refreshAccessToken() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? refreshToken = preferences.getString('refresh-token');

      if (refreshToken == null) {
        debugPrint('No refresh token found');
        return null;
      }

      debugPrint('Refreshing access token...');
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

  Future<void> signOutUser({required context}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? refreshToken = preferences.getString('refresh-token');

      // Call logout API to invalidate refresh token on server
      if (refreshToken != null) {
        try {
          await http.post(
            Uri.parse('$uri/api/logout'),
            body: jsonEncode({'refreshToken': refreshToken}),
            headers: <String, String>{
              "Content-Type": "application/json;charset=UTF-8",
            },
          );
        } catch (e) {
          debugPrint('Error calling logout API: $e');
        }
      }

      // Clear local storage
      await preferences.remove('auth-token');
      await preferences.remove('refresh-token');
      await preferences.remove('user');
      providerContainer.read(userProvider.notifier).signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        ((route) => false),
      );
      showSnackBar(context, 'Logout successfully');
    } catch (e) {
      debugPrint('Đã xảy ra lỗi khi đăng xuất: $e');
      showSnackBar(context, 'Đã xảy ra lỗi: $e');
    }
  }

  Future<void> updateUserLocation({
    required BuildContext context,
    required String id,
    required String state,
    required String city,
    required String locality,
    required WidgetRef ref,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('$uri/api/users/$id'),
        body: jsonEncode({'state': state, 'city': city, 'locality': locality}),
        headers: <String, String>{
          "Content-Type": "application/json;charset=UTF-8",
        },
      );

      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () async {
          final responseMap = jsonDecode(res.body);
          final userMap = responseMap['updatedUser'];
          final correctUserJson = jsonEncode(userMap);
          ref.read(userProvider.notifier).setUser(correctUserJson);
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.setString('user', correctUserJson);
          showSnackBar(context, 'Location updated successfully');
        },
      );
    } catch (e) {
      debugPrint('Đã xảy ra lỗi khi cập nhật vị trí: $e');
      showSnackBar(context, 'Đã xảy ra lỗi: $e');
    }
  }

  Future<void> getUserInformation(String id) async {
    try {
      // Use ApiService for automatic token refresh
      final res = await ApiService.authenticatedRequest(
        method: 'GET',
        endpoint: '/api/userInfo/$id',
      );

      if (res.statusCode == 200) {
        final responseMap = jsonDecode(res.body);
        final userMap = responseMap['user'];
        final correctUserJson = jsonEncode(userMap);
        providerContainer.read(userProvider.notifier).setUser(correctUserJson);
      }
    } catch (e) {
      debugPrint('Đã xảy ra lỗi khi lấy thông tin người dùng: $e');
    }
  }

  Future<void> verifyOtp({
    required BuildContext context,
    required String email,
    required String otp,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/verify-otp'),
        body: jsonEncode({'email': email, 'otp': otp}),
        headers: <String, String>{
          "Content-Type": "application/json;charset=UTF-8",
        },
      );
      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'OTP verified successfully. You can now log in.',
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            ((route) => false),
          );
        },
      );
    } catch (e) {
      debugPrint('Đã xảy ra lỗi khi xác minh OTP: $e');
      showSnackBar(context, 'Đã xảy ra lỗi: $e');
    }
  }

  Future<void> deleteAccount({
    required BuildContext context,
    required String id,
    required WidgetRef ref,
  }) async {
    try {
      debugPrint('=== DELETE ACCOUNT START ===');
      debugPrint('User ID: $id');

      // Use ApiService for automatic token refresh
      final res = await ApiService.authenticatedRequest(
        method: 'DELETE',
        endpoint: '/api/users/$id',
      );

      debugPrint('Response Status Code: ${res.statusCode}');
      debugPrint('Response Body: ${res.body}');

      if (!context.mounted) return;

      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () async {
          debugPrint('Delete account SUCCESS');

          SharedPreferences preferences = await SharedPreferences.getInstance();

          // Call logout API to invalidate refresh token
          String? refreshToken = preferences.getString('refresh-token');
          if (refreshToken != null) {
            try {
              await http.post(
                Uri.parse('$uri/api/logout'),
                body: jsonEncode({'refreshToken': refreshToken}),
                headers: <String, String>{
                  "Content-Type": "application/json;charset=UTF-8",
                },
              );
            } catch (e) {
              debugPrint('Error calling logout API: $e');
            }
          }

          // Clear local storage
          await preferences.remove('auth-token');
          await preferences.remove('refresh-token');
          await preferences.remove('user');
          ref.read(userProvider.notifier).signOut();

          if (context.mounted) {
            showSnackBar(context, 'Account deleted successfully');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              ((route) => false),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Đã xảy ra lỗi khi xóa tài khoản: $e');
      if (context.mounted) {
        showSnackBar(context, 'Đã xảy ra lỗi: $e');
      }
    }
  }
}
