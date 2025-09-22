import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vanh_store_app/global_variables.dart';
import 'package:vanh_store_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:vanh_store_app/services/manage_http_response.dart';
import 'package:vanh_store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:vanh_store_app/views/screens/main_screen.dart';

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
      manageHtppResponse(
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
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          "Content-Type": "application/json;charset=UTF-8",
        },
      );
      manageHtppResponse(
        res: res,
        context: context,
        onSuccess: () {
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
}
