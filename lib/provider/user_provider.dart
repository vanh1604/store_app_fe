import 'package:flutter_riverpod/legacy.dart';
import 'package:vanh_store_app/models/user.dart';

class UserProvider extends StateNotifier<User?> {
  UserProvider()
    : super(
        User(
          id: '',
          fullName: '',
          state: '',
          city: '',
          locality: '',
          email: '',
          password: '',
          token: '',
        ),
      );
  User? get user => state;

  void setUser(String userJson) {
    state = User.fromJson(userJson);
  }

  void signOut() {
    state = null;
  }
}

final userProvider = StateNotifierProvider<UserProvider, User?>(
  (ref) => UserProvider(),
);
