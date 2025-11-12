import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/controllers/category_controller.dart';
import 'package:vanh_store_app/controllers/subcategory_controller.dart';
import 'package:vanh_store_app/models/category.dart';
import 'package:vanh_store_app/models/subcategory.dart';
import 'package:vanh_store_app/views/detail/screens/widgets/subcategory_tile_widget.dart';
import 'package:vanh_store_app/views/screens/nav_screens/widgets/header_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Category>> _categoryFuture;
  Category? _selectedCategory;
  List<Subcategory> _subcategories = [];
  final SubcategoryController _subcategoryController = SubcategoryController();
  @override
  void initState() {
    super.initState();
    _categoryFuture = CategoryController().loadCategories();

    _categoryFuture.then((categories) {
      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categories[0];
        });
        _loadSubcategories(categories[0].name);
      }
    });
  }

  Future<void> _loadSubcategories(String categoryName) async {
    print('Loading subcategories for $categoryName');
    final subcategories = await _subcategoryController
        .getSubCategoriesByCategoryName(categoryName);
    setState(() {
      _subcategories = subcategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.2,
        ),
        child: HeaderWidget(),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade200,
              child: FutureBuilder(
                future: _categoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No categories available"));
                  } else {
                    List<Category> categories = snapshot.data!;
                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            setState(() {
                              _selectedCategory = categories[index];
                            });
                            _loadSubcategories(categories[index].name);
                          },
                          title: Text(
                            categories[index].name,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: _selectedCategory == categories[index]
                                  ? Colors.purple
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: _selectedCategory != null
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _selectedCategory!.name,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 1.7,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(_selectedCategory!.banner),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        _subcategories.isNotEmpty
                            ? GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _subcategories.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 4,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 2 / 3,
                                    ),
                                itemBuilder: (context, index) {
                                  final subcategory = _subcategories[index];
                                  return SubcategoryTileWidget(
                                    image: subcategory.image,
                                    title: subcategory.subCategoryName,
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'No subcategories available',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    letterSpacing: 1.7,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
