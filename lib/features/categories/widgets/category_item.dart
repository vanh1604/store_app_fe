import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/features/categories/controllers/category_controller.dart';

import 'package:vanh_store_app/features/categories/providers/category_provider.dart';
import 'package:vanh_store_app/features/categories/screens/inner_category_screen.dart';
import 'package:vanh_store_app/core/widgets/reusable_text_widget.dart';

class CategoryItemWidget extends ConsumerStatefulWidget {
  const CategoryItemWidget({super.key});

  @override
  ConsumerState<CategoryItemWidget> createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends ConsumerState<CategoryItemWidget> {
  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final CategoryController categoryController = CategoryController();
    try {
      final categories = await categoryController.loadCategories();
      ref.read(categoryProvider.notifier).setCategories(categories);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableTextWidget(title: 'Danh mục'),
        const SizedBox(height: 10),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InnerCategoryScreen(category: categories[index]),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: categories[index].image,
                            fit: BoxFit.cover,
                            width: 47,
                            height: 47,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          categories[index].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
