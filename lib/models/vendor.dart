import 'dart:convert';

class Vendor {
  final String id;
  final String fullName;
  final String state;
  final String city;
  final String locality;
  final String email;
  final String password;
  final String role;
  final String token;
  final String storeName;
  final String storeImage;
  final String storeDescription;

  Vendor({
    required this.id,
    required this.fullName,
    required this.state,
    required this.city,
    required this.locality,
    required this.email,
    required this.password,
    required this.role,
    required this.token,
    required this.storeName,
    required this.storeImage,
    required this.storeDescription,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      'fullName': fullName,
      'email': email,
      'state': state,
      'city': city,
      'locality': locality,
      'password': password,
      'role': role,
      'token': token,
      'storeName': storeName,
      'storeImage': storeImage,
      'storeDescription': storeDescription,
    };
  }

  String toJson() => json.encode(toMap());

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['_id'] ?? '',
      fullName: map['fullName'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      locality: map['locality'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      token: map['token'] ?? '',
      storeName: map['storeName'] ?? '',
      storeImage: map['storeImage'] ?? '',
      storeDescription: map['storeDescription'] ?? '',
    );
  }

  factory Vendor.fromJson(String source) =>
      Vendor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Vendor(id: $id, fullName: $fullName, email: $email, state: $state, city: $city, locality: $locality, role: $role, storeName: $storeName)';
  }
}
