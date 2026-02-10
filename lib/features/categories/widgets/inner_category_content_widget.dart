import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/features/products/controllers/product_controller.dart';
import 'package:vanh_store_app/features/categories/controllers/subcategory_controller.dart';
import 'package:vanh_store_app/features/categories/models/category.dart';
import 'package:vanh_store_app/features/products/models/product.dart';
import 'package:vanh_store_app/features/categories/models/subcategory.dart';
import 'package:vanh_store_app/features/products/screens/subcategory_product_screen.dart';
import 'package:vanh_store_app/features/categories/widgets/inner_banner_widget.dart';
import 'package:vanh_store_app/features/categories/widgets/subcategory_tile_widget.dart';
import 'package:vanh_store_app/features/products/widgets/product_item_widget.dart';
import 'package:vanh_store_app/core/widgets/reusable_text_widget.dart';

class InnerCategoryContentWidget extends StatefulWidget {
  const InnerCategoryContentWidget({super.key, required this.category});
  final Category? category;

  @override
  _InnerCategoryContentWidgetState createState() =>
      _InnerCategoryContentWidgetState();
}

class _InnerCategoryContentWidgetState
    extends State<InnerCategoryContentWidget> {
  late Future<List<Subcategory>> _subcategories;
  late Future<List<Product>> _futureProducts;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _subcategories = SubcategoryController().getSubCategoriesByCategoryName(
      widget.category!.name,
    );
    _futureProducts = ProductController().loadProductByCategory(
      widget.category!.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: InnerBannerWidget(imageUrl: widget.category?.banner ?? ''),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Shop By Subcategories For ${widget.category?.name}',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
            SizedBox(height: 10),
            FutureBuilder(
              future: _subcategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: 150,
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No subcategories available"));
                } else {
                  List<Subcategory> subcategories = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: List.generate(
                        (subcategories.length / 7).ceil(),
                        (setIndex) {
                          final start = setIndex * 7;
                          // Use min() to prevent RangeError
                          final end = (setIndex + 1) * 7;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: subcategories
                                  .sublist(
                                    start,
                                    end > subcategories.length
                                        ? subcategories.length
                                        : end,
                                  )
                                  .map<Widget>((subcategory) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SubcategoryProductScreen(
                                                  subcaregoryName: subcategory
                                                      .subCategoryName,
                                                ),
                                          ),
                                        );
                                      },
                                      child: SubcategoryTileWidget(
                                        image: subcategory.image,
                                        title: subcategory.subCategoryName,
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            ReusableTextWidget(title: 'Popular Product', subtitle: 'View All'),
            FutureBuilder<List<Product>>(
              future: _futureProducts,
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
            ),
          ],
        ),
      ),
    );
  }
}
