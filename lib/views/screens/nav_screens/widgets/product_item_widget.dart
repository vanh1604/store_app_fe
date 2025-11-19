import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/models/product.dart';

class ProductItemWidget extends StatelessWidget {
  const ProductItemWidget({super.key, required this.product});
  final Product? product;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  product!.images[0],
                  height: 170,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 15,
                  right: 2,
                  child: Image.asset('assets/icons/love.png'),
                  width: 26,
                  height: 26,
                ),
                Positioned(
                  child: Image.asset('assets/icons/cart.png'),
                  bottom: 0,
                  right: 0,
                  width: 26,
                  height: 26,
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product!.name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                '${product!.price.toStringAsFixed(2)}\$',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            product!.category,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: Color(0xff868D94),
            ),
          ),
        ],
      ),
    );
  }
}
