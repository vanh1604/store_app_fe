import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/controllers/subcategory_controller.dart';
import 'package:vanh_store_app/models/category.dart';
import 'package:vanh_store_app/models/subcategory.dart';
import 'package:vanh_store_app/views/detail/screens/widgets/inner_banner_widget.dart';
import 'package:vanh_store_app/views/detail/screens/widgets/subcategory_tile_widget.dart';

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
  final SubcategoryController _subcategoryController = SubcategoryController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _subcategories = _subcategoryController.getSubCategoriesByCategoryName(
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
                                    return SubcategoryTileWidget(
                                      image: subcategory.image,
                                      title: subcategory.subCategoryName,
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
          ],
        ),
      ),
    );
  }
}
