import 'dart:convert';

class User {
  final String id;
  final String fullName;
  final String province;
  final String district;
  final String ward;
  final String address;
  final String email;
  final String number;
  final String password;
  final String token;

  User({
    required this.id,
    required this.fullName,
    required this.province,
    required this.district,
    required this.ward,
    required this.address,
    required this.email,
    required this.number,
    required this.password,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      'fullName': fullName,
      'email': email,
      'number': number,
      'province': province,
      'district': district,
      'ward': ward,
      'address': address,
      'password': password,
      'token': token,
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      fullName: map['fullName'] ?? '',
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      ward: map['ward'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      number: map['number'] ?? '',
      password: map['password'] ?? '',
      token: map['token'] ?? '',
    );
  }

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}