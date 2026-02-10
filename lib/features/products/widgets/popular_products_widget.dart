import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/features/products/controllers/product_controller.dart';
import 'package:vanh_store_app/features/products/models/product.dart';
import 'package:vanh_store_app/features/products/providers/product_provider.dart';
import 'package:vanh_store_app/features/products/widgets/product_item_widget.dart';

class PopularProductsWidget extends ConsumerStatefulWidget {
  const PopularProductsWidget({super.key});

  @override
  ConsumerState<PopularProductsWidget> createState() =>
      _PopularProductsWidgetState();
}

class _PopularProductsWidgetState extends ConsumerState<PopularProductsWidget> {
  @override
  void initState() {
    super.initState();
    fetchPopularProducts();
  }

  Future<void> fetchPopularProducts() async {
    final ProductController productController = ProductController();
    try {
      final products = await productController.loadPopularProducts();
      ref.read(productProvider.notifier).setProducts(products);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final popularProducts = ref.watch(productProvider);
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularProducts.length,
        itemBuilder: (context, index) {
          Product product = popularProducts[index];
          return ProductItemWidget(product: product);
        },
      ),
    );
  }
}
