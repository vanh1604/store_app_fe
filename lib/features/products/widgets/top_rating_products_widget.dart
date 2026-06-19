import 'package:flutter/material.dart';
import 'package:vanh_store_app/features/products/controllers/product_controller.dart';
import 'package:vanh_store_app/features/products/models/product.dart';
import 'package:vanh_store_app/features/products/widgets/product_item_widget.dart';

class TopRatingProductsWidget extends StatefulWidget {
  const TopRatingProductsWidget({super.key});

  @override
  State<TopRatingProductsWidget> createState() =>
      _TopRatingProductsWidgetState();
}

class _TopRatingProductsWidgetState extends State<TopRatingProductsWidget> {
  List<Product> _topRatedProducts = [];

  @override
  void initState() {
    super.initState();
    fetchTopRatedProducts();
  }

  Future<void> fetchTopRatedProducts() async {
    final ProductController productController = ProductController();
    try {
      final products = await productController.topRatedProducts();
      if (mounted) {
        setState(() {
          _topRatedProducts = products;
        });
      }
    } catch (e) {
      debugPrint('Error fetching top rated products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topRatedProducts = _topRatedProducts;
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topRatedProducts.length,
        itemBuilder: (context, index) {
          Product product = topRatedProducts[index];
          return ProductItemWidget(
            key: ValueKey('toprated-${product.id}'),
            product: product,
            heroTag: 'toprated-${product.id}',
          );
        },
      ),
    );
  }
}
