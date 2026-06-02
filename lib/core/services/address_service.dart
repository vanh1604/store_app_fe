import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressService {
  static const String _baseUrl = 'https://provinces.open-api.vn/api';

  Future<List<dynamic>> getProvinces() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/p/'));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getDistricts(int provinceCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/p/$provinceCode?depth=2'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['districts'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getWards(int districtCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/d/$districtCode?depth=2'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['wards'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
