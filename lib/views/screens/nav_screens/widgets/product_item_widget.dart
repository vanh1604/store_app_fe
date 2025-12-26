import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/models/product.dart';
import 'package:vanh_store_app/provider/cart_provider.dart';
import 'package:vanh_store_app/provider/favorite_provider.dart';
import 'package:vanh_store_app/services/manage_http_response.dart';
import 'package:vanh_store_app/views/detail/screens/product_detail_screen.dart';

class ProductItemWidget extends ConsumerStatefulWidget {
  const ProductItemWidget({super.key, required this.product});
  final Product? product;

  @override
  ConsumerState<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends ConsumerState<ProductItemWidget> {
  @override
  Widget build(BuildContext context) {
    int _selectedQuantity = 1;
    final cartproviderData = ref.watch(cartProvider.notifier);
    final favoriteProviderData = ref.read(favoriteProvider.notifier);
    final cartData = ref.watch(cartProvider);
    final isInCart = cartData.containsKey(widget.product!.id);
    ref.watch(favoriteProvider);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(productId: widget.product!.id),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Image.network(
                    widget.product!.images[0],
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 5,
                    right: 0,
                    child: InkWell(
                      child:
                          favoriteProviderData.getFavorite.containsKey(
                            widget.product!.id,
                          )
                          ? Icon(Icons.favorite, color: Colors.red)
                          : Icon(Icons.favorite_border, color: Colors.black87),
                      onTap: () {
                        favoriteProviderData.addProductToFavorite(
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
                          "added ${widget.product!.name} to favorite",
                        );
                      },
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    width: 26,
                    height: 26,
                    child: InkWell(
                      onTap: isInCart
                          ? null
                          : () {
                              for (int i = 0; i < _selectedQuantity; i++) {
                                cartproviderData.addProductToCart(
                                  productName: widget.product!.name,
                                  quantity: 1,
                                  price: widget.product!.price,
                                  image: widget.product!.images,
                                  category: widget.product!.category,
                                  vendorId: widget.product!.vendorId,
                                  productId: widget.product!.id,
                                  productDescription:
                                      widget.product!.description,
                                  productQuantity: widget.product!.quantity,
                                  fullName: widget.product!.fullName,
                                );
                              }
                              showSnackBar(
                                context,
                                'Added ${_selectedQuantity}x ${widget.product!.name} to cart',
                              );
                            },
                      child: Image.asset('assets/icons/cart.png'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product!.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '${widget.product!.price.toStringAsFixed(2)}\$',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            widget.product!.averageRating == 0
                ? SizedBox()
                : Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        widget.product!.averageRating.toStringAsFixed(1),
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 4),
            Text(
              widget.product!.category,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                color: Color(0xff868D94),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
