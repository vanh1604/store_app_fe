import 'package:flutter/material.dart';
import 'package:vanh_store_app/models/category.dart';
import 'package:vanh_store_app/views/detail/screens/widgets/inner_category_content_widget.dart';
import 'package:vanh_store_app/views/detail/screens/widgets/inner_header_widget.dart';
import 'package:vanh_store_app/views/screens/nav_screens/account_screen.dart';
import 'package:vanh_store_app/views/screens/nav_screens/cart_screen.dart';
import 'package:vanh_store_app/views/screens/nav_screens/category_screen.dart';
import 'package:vanh_store_app/views/screens/nav_screens/favorite_screen.dart';
import 'package:vanh_store_app/views/screens/nav_screens/store_screen.dart';

class InnerCategoryScreen extends StatefulWidget {
  const InnerCategoryScreen({super.key, required this.category});
  final Category? category;

  @override
  _InnerCategoryScreenState createState() => _InnerCategoryScreenState();
}

class _InnerCategoryScreenState extends State<InnerCategoryScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      InnerCategoryContentWidget(category: widget.category),
      FavoriteScreen(),
      CategoryScreen(),
      StoreScreen(),
      CartScreen(),
      AccountScreen(),
    ];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.2,
        ),
        child: InnerHeaderWidget(),
      ),
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
