import 'package:flutter/material.dart';
import 'package:vanh_store_app/features/categories/models/category.dart';
import 'package:vanh_store_app/features/categories/widgets/inner_category_content_widget.dart';
import 'package:vanh_store_app/features/categories/widgets/inner_header_widget.dart';

class InnerCategoryScreen extends StatelessWidget {
  const InnerCategoryScreen({super.key, required this.category});
  final Category? category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.2,
        ),
        child: InnerHeaderWidget(),
      ),
      body: InnerCategoryContentWidget(category: category),
    );
  }
}
