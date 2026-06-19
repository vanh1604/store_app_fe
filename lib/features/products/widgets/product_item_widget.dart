import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/features/products/models/product.dart';
import 'package:vanh_store_app/features/favorites/providers/favorite_provider.dart';
import 'package:vanh_store_app/core/services/http_response_handler.dart';
import 'package:vanh_store_app/features/products/screens/product_detail_screen.dart';
import 'package:vanh_store_app/core/utils/formatters.dart';

class ProductItemWidget extends ConsumerStatefulWidget {
  const ProductItemWidget({super.key, required this.product, this.heroTag});
  final Product? product;
  final String? heroTag;

  @override
  ConsumerState<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends ConsumerState<ProductItemWidget> {

  @override
  Widget build(BuildContext context) {
    final favoriteProviderData = ref.read(favoriteProvider.notifier);
    // Theo dõi favoriteProvider để rebuild icon yêu thích khi danh sách thay đổi.
    ref.watch(favoriteProvider);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: widget.product!.id,
              heroTag: widget.heroTag ?? 'product-${widget.product!.id}',
            ),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 170,
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xffF8F9FA)),
                child: Stack(
                  children: [
                    Hero(
                      tag: widget.heroTag ?? 'product-${widget.product!.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.product!.images[0],
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withOpacity(0.9),
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            final isFavorite = favoriteProviderData.getFavorite
                                .containsKey(widget.product!.id);
                            favoriteProviderData.toggleFavorite(
                              productName: widget.product!.name,
                              quantity: 1,
                              price: widget.product!.price,
                              image: widget.product!.images,
                              category: widget.product!.category,
                              vendorId: widget.product!.vendorId,
                              productId: widget.product!.id,
                              productDescription: widget.product!.description,
                              productQuantity: widget.product!.quantity,
                              fullName: widget.product!.fullName,
                            );
                            showSnackBar(
                              context,
                              isFavorite
                                  ? "Đã xóa ${widget.product!.name} khỏi danh sách yêu thích"
                                  : "Đã thêm ${widget.product!.name} vào danh sách yêu thích",
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child:
                                favoriteProviderData.getFavorite.containsKey(
                                  widget.product!.id,
                                )
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  )
                                : const Icon(
                                    Icons.favorite_border,
                                    color: Colors.black87,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product!.category,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: const Color(0xffADADAD),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 36, // Fixed height for two lines of name
                    child: Text(
                      widget.product!.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xff253D4E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange.shade400, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        widget.product!.averageRating.toStringAsFixed(1),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: const Color(0xff7E7E7E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${formatCurrency(widget.product!.price)} VND',
                          style: GoogleFonts.quicksand(
                            fontSize: 15,
                            color: const Color(0xff3BB77E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
