import 'package:flutter/material.dart';
import 'package:vanh_store_app/controllers/auth_controller.dart';
import 'package:vanh_store_app/views/detail/screens/order_screen.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});
  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              // await authController.signOutUser(context: context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return OrderScreen();
                  },
                ),
              );
            },
            child: Text('My Orders'),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await authController.signOutUser(context: context);
            },
            child: Text('Sign Out'),
          ),
        ),
      ],
    );
  }
}
