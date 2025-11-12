import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/controllers/category_controller.dart';
import 'package:vanh_store_app/models/category.dart';
import 'package:vanh_store_app/views/detail/screens/inner_category_screen.dart';
import 'package:vanh_store_app/views/screens/nav_screens/widgets/reusable_text_widget.dart';

class CategoryItemWidget extends StatefulWidget {
  const CategoryItemWidget({super.key});

  @override
  State<CategoryItemWidget> createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends State<CategoryItemWidget> {
  late Future<List<Category>> _categoryFuture;

  @override
  void initState() {
    super.initState();
    _categoryFuture = CategoryController().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableTextWidget(title: 'Categories', subtitle: "View All"),
        SizedBox(height: 10),
        FutureBuilder(
          future: _categoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 150,
                child: Center(child: Text("Error: ${snapshot.error}")),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No categories available"));
            } else {
              List<Category> categories = snapshot.data!;
              return GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InnerCategoryScreen(category: categories[index]),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Image.network(
                            categories[index].image,
                            fit: BoxFit.cover,
                            width: 47,
                            height: 47,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            categories[index].name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
