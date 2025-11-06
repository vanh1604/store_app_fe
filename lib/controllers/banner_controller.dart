import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vanh_store_app/global_variables.dart';
import 'package:vanh_store_app/models/banner.dart';

class BannerController {
  //fetch banners
  Future<List<BannerModel>> loadBanners() async {
    try {
      http.Response res = await http.get(
        Uri.parse("$uri/api/getbanner"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        List<dynamic> data = responseData['banner'] ?? [];
        List<BannerModel> banners = data
            .map((banner) => BannerModel.fromJson(banner))
            .toList();
        return banners;
      } else {
        throw Exception("Failed to load banners");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An error occurred while loading banners: $e');
    }
  }
}
