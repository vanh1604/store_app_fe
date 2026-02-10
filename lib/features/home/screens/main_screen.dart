import 'package:flutter/material.dart';
import 'package:vanh_store_app/features/account/screens/account_screen.dart';
import 'package:vanh_store_app/features/cart/screens/cart_screen.dart';
import 'package:vanh_store_app/features/categories/screens/category_screen.dart';
import 'package:vanh_store_app/features/favorites/screens/favorite_screen.dart';
import 'package:vanh_store_app/features/home/screens/home_screen.dart';
import 'package:vanh_store_app/features/vendors/screens/store_screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    FavoriteScreen(),
    CategoryScreen(),
    StoreScreen(),
    CartScreen(),
    AccountScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/home.png", width: 25),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/love.png", width: 25),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category, size: 25),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/mart.png", width: 25),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/cart.png", width: 25),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/user.png", width: 25),
            label: 'Account',
          ),
        ],
      ),
      body: _pages[_pageIndex],
    );
  }
}
