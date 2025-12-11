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

  void updateUser({
    required String state,
    required String city,
    required String locality,
  }) {
    if (this.state != null) {
      this.state = User(
        id: this.state!.id,
        fullName: this.state!.fullName,
        state: state,
        city: city,
        locality: locality,
        email: this.state!.email,
        password: this.state!.password,
        token: this.state!.token,
      );
    }
  }
}

final userProvider = StateNotifierProvider<UserProvider, User?>(
  (ref) => UserProvider(),
);
