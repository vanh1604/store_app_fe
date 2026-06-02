import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:vanh_store_app/features/products/controllers/product_controller.dart';
import 'package:vanh_store_app/features/products/models/product.dart';
import 'package:vanh_store_app/features/cart/providers/cart_provider.dart';
import 'package:vanh_store_app/features/favorites/providers/favorite_provider.dart';
import 'package:vanh_store_app/features/products/providers/related_product_provider.dart';
import 'package:vanh_store_app/features/products/widgets/product_reviews_widget.dart';
import 'package:vanh_store_app/core/services/http_response_handler.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId, this.heroTag});
  final String? productId;
  final String? heroTag;
  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late Product _productData;
  bool _isLoading = true;
  bool _hasError = false;
  int _currentImageIndex = 0;
  int _selectedQuantity = 1;
  String? _selectedVariantId;
  String? _selectedSize;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  void initState() {
    super.initState();
    _fetchProductData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductData() async {
    try {
      final data = await ProductController().loadProductById(widget.productId!);
      if (mounted) {
        setState(() {
          _productData = data;
          _isLoading = false;
        });
        _animationController.forward();

        // Fetch related products
        _fetchRelatedProducts();
      }
    } catch (e) {
      debugPrint("Lỗi load sản phẩm: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _fetchRelatedProducts() async {
    try {
      final relatedProducts = await ProductController().relatedProducts(widget.productId!);
      if (mounted) {
        ref.read(relatedProductProvider.notifier).setProducts(relatedProducts);
      }
    } catch (e) {
      debugPrint("Lỗi load related products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartproviderData = ref.watch(cartProvider.notifier);
    final favoriteProviderData = ref.read(favoriteProvider.notifier);
    ref.watch(favoriteProvider);
    final cartData = ref.watch(cartProvider);

    // Determine effective cart key for the current selection
    final productId = widget.productId ?? '';
    final effectiveCartKey = _selectedVariantId != null
        ? '${productId}_$_selectedVariantId'
        : productId;
    final isInCart = cartData.containsKey(effectiveCartKey);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3C55EF)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading product...',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Không thể tải sản phẩm',
                style: GoogleFonts.quicksand(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() { _isLoading = true; _hasError = false; });
                  _fetchProductData();
                },
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Floating Actions
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon:
                      favoriteProviderData.getFavorite.containsKey(
                        _productData.id,
                      )
                      ? Icon(Icons.favorite, color: Colors.red)
                      : Icon(Icons.favorite_border, color: Colors.black87),
                  onPressed: () {
                    final isFavorite = favoriteProviderData.getFavorite.containsKey(_productData.id);
                    favoriteProviderData.toggleFavorite(
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
                      isFavorite 
                        ? "Đã xóa ${_productData.name} khỏi danh sách yêu thích"
                        : "Đã thêm ${_productData.name} vào danh sách yêu thích",
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _buildImageCarousel()),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  _buildRatingSection(),
                  if (_productData.hasVariants) _buildSizeSelector(),
                  _buildStockInfo(),
                  _buildQuantitySelector(),
                  _buildVendorInfo(),
                  _buildDescriptionSection(),
                  ProductReviewsWidget(productId: _productData.id),
                  _buildRelatedProductsSection(),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isInCart, cartproviderData),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      color: Color(0xFFF5F7FF),
      child: Stack(
        children: [
          PageView.builder(
            itemCount: _productData.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageWidget = Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: _productData.images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                ),
              );

              if (index == 0) {
                return Hero(
                  tag: widget.heroTag ?? 'product-${widget.productId}',
                  child: imageWidget,
                );
              }
              return imageWidget;
            },
          ),
          // Image indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _productData.images.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentImageIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? Color(0xFF3C55EF)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _productData.name,
                  style: GoogleFonts.quicksand(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF3C55EF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _productData.category,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C55EF),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                () {
                  if (_selectedVariantId != null) {
                    final variant = _productData.variants.firstWhere(
                      (v) => v.id == _selectedVariantId,
                      orElse: () => _productData.variants.first,
                    );
                    return _formatCurrency(variant.price);
                  }
                  return _formatCurrency(_productData.price);
                }(),
                style: GoogleFonts.quicksand(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C55EF),
                  height: 1,
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'VND',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    if (_productData.totalRatings == 0) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.star_border, color: Colors.grey[400], size: 20),
              SizedBox(width: 8),
              Text(
                'No ratings yet',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF9E6), Color(0xFFFFF4D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFFFE5B4)),
        ),
        child: Row(
          children: [
            RatingBar(
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              initialRating: _productData.averageRating,
              maxRating: 5,
              size: 22,
              filledColor: Color(0xFFFFB800),
              emptyColor: Colors.grey[300]!,
              onRatingChanged: (rating) {},
            ),
            SizedBox(width: 12),
            Text(
              _productData.averageRating.toStringAsFixed(1),
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8C00),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '(${_productData.totalRatings} reviews)',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo() {
    int stockQty;
    if (_selectedVariantId != null) {
      final variant = _productData.variants.firstWhere(
        (v) => v.id == _selectedVariantId,
        orElse: () => _productData.variants.first,
      );
      stockQty = variant.quantity;
    } else {
      stockQty = _productData.quantity;
    }
    final inStock = stockQty > 0;
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: inStock ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            inStock ? '$stockQty items in stock' : 'Out of stock',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: inStock ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onPressed: _selectedQuantity > 1
                      ? () {
                          setState(() {
                            _selectedQuantity--;
                          });
                        }
                      : null,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    '$_selectedQuantity',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onPressed: () {
                    int maxQty;
                    if (_selectedVariantId != null) {
                      final variant = _productData.variants.firstWhere(
                        (v) => v.id == _selectedVariantId,
                        orElse: () => _productData.variants.first,
                      );
                      maxQty = variant.quantity;
                    } else {
                      maxQty = _productData.quantity;
                    }
                    return _selectedQuantity < maxQty
                        ? () {
                            setState(() {
                              _selectedQuantity++;
                            });
                          }
                        : null;
                  }(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null ? Color(0xFF3C55EF) : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3C55EF), Color(0xFF6B7FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _productData.fullName.isNotEmpty
                      ? _productData.fullName[0].toUpperCase()
                      : 'V',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sold by',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _productData.fullName.isNotEmpty
                        ? _productData.fullName
                        : 'Store',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 12),
          Text(
            _productData.description,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProductsSection() {
    final relatedProducts = ref.watch(relatedProductProvider);

    if (relatedProducts.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Text(
                'Có thể bạn cũng thích',
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF3C55EF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${relatedProducts.length}',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C55EF),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) {
              final product = relatedProducts[index];
              return _buildRelatedProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductCard(Product product) {
    final favoriteProviderData = ref.read(favoriteProvider.notifier);
    final isFavorite = favoriteProviderData.getFavorite.containsKey(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: product.images.isNotEmpty ? product.images[0] : '',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      height: 140,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey[600],
                        size: 18,
                      ),
                      onPressed: () {
                        favoriteProviderData.addProductToFavorite(
                          productName: product.name,
                          quantity: 1,
                          price: product.price,
                          image: product.images,
                          category: product.category,
                          vendorId: product.vendorId,
                          productId: product.id,
                          productDescription: product.description,
                          productQuantity: product.quantity,
                          fullName: product.fullName,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    Spacer(),
                    // Rating
                    if (product.totalRatings > 0)
                      Row(
                        children: [
                          Icon(Icons.star, color: Color(0xFFFFB800), size: 14),
                          SizedBox(width: 4),
                          Text(
                            product.averageRating.toStringAsFixed(1),
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '(${product.totalRatings})',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 4),
                    // Price
                    Text(
                      '${_formatCurrency(product.price)} VND',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C55EF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn Size',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _productData.variants.map((variant) {
              final isSelected = _selectedVariantId == variant.id;
              final isOutOfStock = variant.quantity == 0;
              return GestureDetector(
                onTap: isOutOfStock
                    ? null
                    : () {
                        setState(() {
                          _selectedVariantId = variant.id;
                          _selectedSize = variant.label; // "M / Đỏ" hoặc "M"
                          _selectedQuantity = 1;
                        });
                      },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(0xFF3C55EF)
                        : isOutOfStock
                            ? Colors.grey[100]
                            : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Color(0xFF3C55EF)
                          : isOutOfStock
                              ? Colors.grey[300]!
                              : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        variant.label,
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isOutOfStock
                                  ? Colors.grey[400]
                                  : Color(0xFF1A1A1A),
                        ),
                      ),
                      if (isOutOfStock)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StrikethroughPainter(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isInCart, cartproviderData) {
    int effectiveStock = _productData.quantity;
    if (_selectedVariantId != null) {
      final variant = _productData.variants.firstWhere(
        (v) => v.id == _selectedVariantId,
        orElse: () => _productData.variants.first,
      );
      effectiveStock = variant.quantity;
    }
    final bool isOutOfStock = effectiveStock == 0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: (isInCart || isOutOfStock) ? Colors.grey[300] : Color(0xFF3C55EF),
                borderRadius: BorderRadius.circular(16),
                elevation: (isInCart || isOutOfStock) ? 0 : 4,
                shadowColor: Color(0xFF3C55EF).withValues(alpha: 0.4),
                child: InkWell(
                  onTap: (isInCart || isOutOfStock)
                      ? null
                      : () {
                          if (_productData.hasVariants && _selectedVariantId == null) {
                            showSnackBar(context, 'Vui lòng chọn size trước khi thêm vào giỏ');
                            return;
                          }
                          double effectivePrice = _productData.price;
                          if (_selectedVariantId != null) {
                            final variant = _productData.variants.firstWhere(
                              (v) => v.id == _selectedVariantId,
                            );
                            effectivePrice = variant.price;
                          }
                          for (int i = 0; i < _selectedQuantity; i++) {
                            cartproviderData.addProductToCart(
                              productName: _productData.name,
                              quantity: 1,
                              price: effectivePrice,
                              image: _productData.images,
                              category: _productData.category,
                              vendorId: _productData.vendorId,
                              productId: _productData.id,
                              productDescription: _productData.description,
                              productQuantity: effectiveStock,
                              fullName: _productData.fullName,
                              selectedSize: _selectedSize,
                              variantId: _selectedVariantId,
                            );
                          }
                          showSnackBar(
                            context,
                            'Đã thêm ${_selectedQuantity}x ${_productData.name}${_selectedSize != null ? ' (Kích thước: $_selectedSize)' : ''} vào giỏ hàng',
                          );
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isOutOfStock ? Icons.remove_shopping_cart : (isInCart ? Icons.check_circle : Icons.shopping_bag),
                          color: (isInCart || isOutOfStock) ? Colors.grey[600] : Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Text(
                          isOutOfStock ? 'Hết hàng' : (isInCart ? 'Đã trong giỏ' : 'Thêm vào giỏ'),
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: (isInCart || isOutOfStock) ? Colors.grey[600] : Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

