import 'dart:convert';

class User {
  final String id;
  final String fullName;
  final String state;
  final String city;
  final String locality;
  final String email;
  final String password;
  final String token;

  User({
    required this.id,
    required this.fullName,
    required this.state,
    required this.city,
    required this.locality,
    required this.email,
    required this.password,
    required this.token,
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
      'token': token,
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'],
      fullName: map['fullName'],
      state: map['state'],
      city: map['city'],
      locality: map['locality'],
      email: map['email'],
      password: map['password'],
      token: map['token'],
    );
  }

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
