import 'package:flutter/material.dart';
import 'package:vanh_store_app/features/banners/widgets/banner_widget.dart';
import 'package:vanh_store_app/features/categories/widgets/category_item.dart';
import 'package:vanh_store_app/features/chat/screens/chat_screen.dart';
import 'package:vanh_store_app/features/home/widgets/header_widget.dart';
import 'package:vanh_store_app/features/products/widgets/popular_products_widget.dart';
import 'package:vanh_store_app/core/widgets/reusable_text_widget.dart';
import 'package:vanh_store_app/features/products/widgets/top_rating_products_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Light background for contrast
      body: Column(
        children: [
          const HeaderWidget(), // Flexible header at the top
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80), // Padding for FAB
              children: [
                const SizedBox(height: 10),
                const BannerWidget(),
                const SizedBox(height: 20),
                const CategoryItemWidget(),
                const SizedBox(height: 25),
                const ReusableTextWidget(title: 'Sản phẩm phổ biến'),
                const SizedBox(height: 10),
                const PopularProductsWidget(),
                const SizedBox(height: 25),
                const ReusableTextWidget(title: 'Sản phẩm được đánh giá cao'),
                const SizedBox(height: 10),
                const TopRatingProductsWidget(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: Colors.purple,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tooltip: 'Trợ lý AI',
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
    );
  }
}
