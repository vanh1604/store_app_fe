import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:vanh_store_app/features/products/controllers/product_review_controller.dart';
import 'package:vanh_store_app/features/products/models/product_review.dart';

class ProductReviewsWidget extends StatefulWidget {
  final String productId;

  const ProductReviewsWidget({super.key, required this.productId});

  @override
  State<ProductReviewsWidget> createState() => _ProductReviewsWidgetState();
}

class _ProductReviewsWidgetState extends State<ProductReviewsWidget> {
  final ProductReviewController _reviewController = ProductReviewController();
  late Future<List<ProductReview>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _reviewController.getReviewsByProductId(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductReview>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Lỗi tải đánh giá: ${snapshot.error}',
              style: GoogleFonts.quicksand(color: Colors.red),
            ),
          );
        }

        final List<ProductReview> reviews = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đánh giá khách hàng (${reviews.length})',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    'Chưa có đánh giá chi tiết nào cho sản phẩm này.',
                    style: GoogleFonts.quicksand(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.grey.shade100, height: 1),
                ),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  // Ensure name is not empty for avatar
                  final String displayName = review.fullName.trim().isEmpty
                      ? 'Anonymous'
                      : review.fullName;
                  final String initial = displayName[0].toUpperCase();

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.shade50,
                              child: Text(
                                initial,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RatingBar.readOnly(
                                    filledIcon: Icons.star,
                                    emptyIcon: Icons.star_border,
                                    initialRating: review.rating,
                                    maxRating: 5,
                                    size: 14,
                                    filledColor: Colors.amber,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            review.review,
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
