import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vanh_store_app/core/config/global_variables.dart';
import 'package:vanh_store_app/features/vendors/models/vendor.dart';

class VendorController {
  Future<List<Vendor>> fetchAllVendorsStore() async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/vendors/stores"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        List<dynamic> vendorsData = data['vendors'] ?? [];
        if (vendorsData.isNotEmpty) {
          return vendorsData.map((vendor) => Vendor.fromMap(vendor)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception("Failed to load vendors");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
