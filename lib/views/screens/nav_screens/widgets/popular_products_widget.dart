import 'package:flutter/material.dart';
import 'package:vanh_store_app/controllers/product_controller.dart';
import 'package:vanh_store_app/models/product.dart';
import 'package:vanh_store_app/views/screens/nav_screens/widgets/product_item_widget.dart';

class PopularProductsWidget extends StatefulWidget {
  const PopularProductsWidget({super.key});

  @override
  _PopularProductsWidgetState createState() => _PopularProductsWidgetState();
}

class _PopularProductsWidgetState extends State<PopularProductsWidget> {
  late Future<List<Product>> _popularProductsFuture;

  @override
  void initState() {
    super.initState();
    _popularProductsFuture = ProductController().loadPopularProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _popularProductsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No popular products found.'));
        } else {
          List<Product> popularProducts = snapshot.data!;
          // You can build your UI with the popularProducts list here
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
      },
    );
  }
}
