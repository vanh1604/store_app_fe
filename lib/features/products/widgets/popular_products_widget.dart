import 'package:flutter/material.dart';
import 'package:vanh_store_app/features/products/controllers/product_controller.dart';
import 'package:vanh_store_app/features/products/models/product.dart';
import 'package:vanh_store_app/features/products/widgets/product_item_widget.dart';

class PopularProductsWidget extends StatefulWidget {
  const PopularProductsWidget({super.key});

  @override
  State<PopularProductsWidget> createState() => _PopularProductsWidgetState();
}

class _PopularProductsWidgetState extends State<PopularProductsWidget> {
  List<Product> _popularProducts = [];

  @override
  void initState() {
    super.initState();
    fetchPopularProducts();
  }

  Future<void> fetchPopularProducts() async {
    final ProductController productController = ProductController();
    try {
      final products = await productController.loadPopularProducts();
      if (mounted) {
        setState(() {
          _popularProducts = products;
        });
      }
    } catch (e) {
      debugPrint('Error fetching popular products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final popularProducts = _popularProducts;
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularProducts.length,
        itemBuilder: (context, index) {
          Product product = popularProducts[index];
          return ProductItemWidget(
            key: ValueKey('popular-${product.id}'),
            product: product,
            heroTag: 'popular-${product.id}',
          );
        },
      ),
    );
  }
}
