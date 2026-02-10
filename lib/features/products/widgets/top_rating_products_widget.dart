import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/features/products/controllers/product_controller.dart';
import 'package:vanh_store_app/features/products/models/product.dart';
import 'package:vanh_store_app/features/products/providers/top_rated_product_provider.dart';
import 'package:vanh_store_app/features/products/widgets/product_item_widget.dart';

class TopRatingProductsWidget extends ConsumerStatefulWidget {
  const TopRatingProductsWidget({super.key});

  @override
  ConsumerState<TopRatingProductsWidget> createState() =>
      _TopRatingProductsWidgetState();
}

class _TopRatingProductsWidgetState
    extends ConsumerState<TopRatingProductsWidget> {
  @override
  void initState() {
    super.initState();
    fetchTopRatedProducts();
  }

  Future<void> fetchTopRatedProducts() async {
    final ProductController productController = ProductController();
    try {
      final products = await productController.topRatedProducts();
      ref.read(topRatedProductProvider.notifier).setProducts(products);
    } catch (e) {
      debugPrint('Error fetching top rated products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topRatedProducts = ref.watch(topRatedProductProvider);
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topRatedProducts.length,
        itemBuilder: (context, index) {
          Product product = topRatedProducts[index];
          return ProductItemWidget(product: product);
        },
      ),
    );
  }
}
