import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/features/categories/controllers/category_controller.dart';
import 'package:vanh_store_app/features/categories/controllers/subcategory_controller.dart';
import 'package:vanh_store_app/features/categories/models/category.dart';
import 'package:vanh_store_app/features/categories/providers/category_provider.dart';
import 'package:vanh_store_app/features/categories/providers/subcategory_provider.dart';
import 'package:vanh_store_app/features/products/screens/subcategory_product_screen.dart';
import 'package:vanh_store_app/features/categories/widgets/subcategory_tile_widget.dart';
import 'package:vanh_store_app/features/home/widgets/header_widget.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});
  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  Category? _selectedCategory;
  bool _isLoadingCategories = true;
  bool _isLoadingSubcategories = false;

  final CategoryController _categoryController = CategoryController();
  final SubcategoryController _subcategoryController = SubcategoryController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    final categories = await _categoryController.loadCategories();

    if (mounted) {
      ref.read(categoryProvider.notifier).setCategories(categories);

      setState(() {
        _isLoadingCategories = false;
      });

      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categories[0];
        });
        _loadSubcategories(categories[0].name);
      }
    }
  }

  Future<void> _loadSubcategories(String categoryName) async {
    setState(() {
      _isLoadingSubcategories = true;
    });

    final subcategories = await _subcategoryController
        .getSubCategoriesByCategoryName(categoryName);

    if (mounted) {
      ref.read(subcategoryProvider.notifier).setSubcategories(subcategories);

      setState(() {
        _isLoadingSubcategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final subcategories = ref.watch(subcategoryProvider);

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
          // Left sidebar - Categories list
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: Offset(2, 0),
                  ),
                ],
              ),
              child: _isLoadingCategories
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.purple),
                    )
                  : categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No categories",
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = _selectedCategory == category;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _loadSubcategories(category.name);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.purple.shade50
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.purple
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              title: Text(
                                category.name,
                                style: GoogleFonts.quicksand(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.purple.shade700
                                      : Colors.black87,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.purple,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Right content - Category details and subcategories
          Expanded(
            flex: 5,
            child: _selectedCategory != null
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category title
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _selectedCategory!.name,
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  letterSpacing: 0.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Category banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _selectedCategory!.banner,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // Subcategories section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Subcategories',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        // Loading or subcategories grid
                        _isLoadingSubcategories
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.purple,
                                  ),
                                ),
                              )
                            : subcategories.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: subcategories.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: 2 / 3,
                                      ),
                                  itemBuilder: (context, index) {
                                    final subcategory = subcategories[index];
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
                                  },
                                ),
                              )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.grid_view_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'No subcategories available',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        SizedBox(height: 24),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Select a category',
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
