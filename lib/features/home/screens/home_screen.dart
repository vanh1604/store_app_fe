import 'package:flutter/material.dart';
import 'package:vanh_store_app/features/banners/widgets/banner_widget.dart';
import 'package:vanh_store_app/features/categories/widgets/category_item.dart';
import 'package:vanh_store_app/features/home/widgets/header_widget.dart';
import 'package:vanh_store_app/features/products/widgets/popular_products_widget.dart';
import 'package:vanh_store_app/core/widgets/reusable_text_widget.dart';
import 'package:vanh_store_app/features/products/widgets/top_rating_products_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.2,
        ),
        child: HeaderWidget(),
      ),
      body: ListView(
        children: [
          BannerWidget(),
          CategoryItemWidget(),
          ReusableTextWidget(title: 'Popular Products', subtitle: 'View All'),
          PopularProductsWidget(),
          SizedBox(height: 20),
          ReusableTextWidget(title: 'Top Rated Products', subtitle: 'View All'),
          TopRatingProductsWidget(),
        ],
      ),
    );
  }
}
