import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanh_store_app/global_variables.dart';
import 'package:vanh_store_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:vanh_store_app/provider/user_provider.dart';
import 'package:vanh_store_app/services/manage_http_response.dart';
import 'package:vanh_store_app/views/screens/authentication_screens/login_screen.dart';
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
            MaterialPageRoute(builder: (context) => LoginScreen()),
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
          String token = jsonDecode(res.body)['token'];
          await preferences.setString('auth-token', token);
          final userJsonMap = jsonDecode(res.body)['user'];
          userJsonMap['token'] = token;
          final userJson = jsonEncode(userJsonMap);
          ref.read(userProvider.notifier).setUser(userJson);
          await preferences.setString('user', userJson);
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

  Future<void> signOutUser({required context}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('auth-token');
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
}
