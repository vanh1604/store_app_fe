import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/models/user.dart';

class UserNotifier extends Notifier<User?> {
  @override
  User? build() {
    // Initial state - empty user
    return User(
      id: '',
      fullName: '',
      state: '',
      city: '',
      locality: '',
      email: '',
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
    required String userState,
    required String city,
    required String locality,
  }) {
    if (state != null) {
      state = User(
        id: state!.id,
        fullName: state!.fullName,
        state: userState,
        city: city,
        locality: locality,
        email: state!.email,
        password: state!.password,
        token: state!.token,
      );
    }
  }
}

final userProvider = NotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});
