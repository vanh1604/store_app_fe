import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/controllers/product_controller.dart';
import 'package:vanh_store_app/models/product.dart';
import 'package:vanh_store_app/provider/cart_provider.dart';
import 'package:vanh_store_app/services/manage_http_response.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String? productId;
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late Product _productData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  @override
  Future<void> _fetchProductData() async {
    try {
      // Gọi controller để lấy dữ liệu
      // Lưu ý: Hàm loadProductById trong Controller CẦN return về dữ liệu
      final data = await ProductController().loadProductById(widget.productId!);

      if (mounted) {
        // Kiểm tra widget còn tồn tại không trước khi setState
        setState(() {
          _productData = data;
          _isLoading = false; // Đã load xong
        });
      }
    } catch (e) {
      print("Lỗi load sản phẩm: $e");
      if (mounted) {
        setState(() {
          _isLoading = false; // Dừng loading kể cả khi lỗi
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _cartprovider = ref.watch(cartProvider.notifier);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Detail',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.favorite_border)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 260,
              height: 275,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 50,
                    child: Container(
                      width: 260,
                      height: 260,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Color(0XFFD8DDFF),
                        borderRadius: BorderRadius.circular(130),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 0,
                    child: Container(
                      width: 216,
                      height: 274,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Color(0xFF9CA8FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SizedBox(
                        height: 300,

                        child: PageView.builder(
                          itemCount: _productData.images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              _productData.images[index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _productData.name,
                  style: GoogleFonts.roboto(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Color(0xFF3C55Ef),
                  ),
                ),
                Text(
                  ' \$${_productData.price}',
                  style: GoogleFonts.roboto(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Color(0xFF3C55Ef),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _productData.category,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About",
                  style: GoogleFonts.lato(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.7,
                    color: Color(0xFF363330),
                  ),
                ),
                Text(
                  _productData.description,
                  style: GoogleFonts.lato(letterSpacing: 2, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            _cartprovider.addProductToCart(
              productName: _productData.name,
              quantity: 1,
              price: _productData.price,
              image: _productData.images,
              category: _productData.category,
              vendorId: _productData.vendorId,
              productId: _productData.id,
              productDescription: _productData.description,
              productQuantity: _productData.quantity,
              fullName: _productData.fullName,
            );
            showSnackBar(
              context,
              'Added ${_productData.name} to cart successfully',
            );
          },
          child: Container(
            width: 386,
            height: 46,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Color(0xFF3B54EE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                'ADD TO CART',
                style: GoogleFonts.mochiyPopOne(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
