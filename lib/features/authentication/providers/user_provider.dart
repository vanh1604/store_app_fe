import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/features/authentication/models/user.dart';

class UserNotifier extends Notifier<User?> {
  @override
  User? build() {
    // Initial state - empty user
    return User(
      id: '',
      fullName: '',
      province: '',
      district: '',
      ward: '',
      address: '',
      email: '',
      number: '',
      password: '',
      token: '',
    );
  }

  User? get user => state;

  void setUser(String userJson) {
    state = User.fromJson(userJson);
  }

  void signOut() {
    state = null;
  }

  void updateUser({
    required String province,
    required String district,
    required String ward,
    required String address,
  }) {
    if (state != null) {
      state = User(
        id: state!.id,
        fullName: state!.fullName,
        province: province,
        district: district,
        ward: ward,
        address: address,
        email: state!.email,
        number: state!.number,
        password: state!.password,
        token: state!.token,
      );
    }
  }
}

final userProvider = NotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});
