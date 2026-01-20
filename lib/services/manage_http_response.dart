import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void manageHttpResponse({
  required http.Response res,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  switch (res.statusCode) {
    case 200:
    case 201:
    case 204:
      onSuccess();
      break;
    case 400:
      showSnackBar(context, json.decode(res.body)['message']);
      break;
    case 404:
      showSnackBar(context, json.decode(res.body)['message']);
      break;
    case 500:
      showSnackBar(context, json.decode(res.body)['error']);
      break;
    default:
      debugPrint('Unhandled status code: ${res.statusCode}');
      debugPrint('Response body: ${res.body}');
      showSnackBar(context, 'Error: Status code ${res.statusCode}');
      break;
  }
}

void showSnackBar(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: EdgeInsets.all(15),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey,
      content: Text(title),
    ),
  );
}
