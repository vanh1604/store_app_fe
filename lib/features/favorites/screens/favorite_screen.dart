import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/features/favorites/providers/favorite_provider.dart';
import 'package:vanh_store_app/features/home/screens/main_screen.dart';

String _formatCurrency(double amount) {
  return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
}

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteData = ref.watch(favoriteProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(favoriteData.length),
      body: favoriteData.isEmpty
          ? _buildEmptyWishlist(context)
          : _buildFavoriteList(favoriteData, ref),
    );
  }

  // ==================== AppBar ====================
  PreferredSizeWidget _buildAppBar(int count) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.deepPurple,
      toolbarHeight: 80,
      title: Text(
        'Yêu thích',
        style: GoogleFonts.lato(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        if (count > 0)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count sản phẩm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== Empty State ====================
  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Danh sách yêu thích trống',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Lưu những sản phẩm bạn yêu thích\ntại đây để mua sau',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Shop Now Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'Bắt đầu mua sắm',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Favorite List ====================
  Widget _buildFavoriteList(Map<String, dynamic> favoriteData, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: favoriteData.length,
      itemBuilder: (context, index) {
        final item = favoriteData.values.toList()[index];
        return _FavoriteItemCard(
          item: item,
          onRemove: () {
            ref.read(favoriteProvider.notifier).removeItem(item.productId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã xóa ${item.productName} khỏi danh sách yêu thích'),
                duration: const Duration(seconds: 1),
                action: SnackBarAction(
                  label: 'Hoàn tác',
                  onPressed: () {
                    ref.read(favoriteProvider.notifier).addProductToFavorite(
                          productName: item.productName,
                          quantity: item.quantity,
                          price: item.price,
                          image: item.image,
                          category: item.category,
                          vendorId: item.vendorId,
                          productId: item.productId,
                          productDescription: item.productDescription,
                          productQuantity: item.productQuantity,
                          fullName: item.fullName,
                        );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==================== Favorite Item Card ====================
class _FavoriteItemCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onRemove;

  const _FavoriteItemCard({
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      onDismissed: (_) => onRemove(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to product detail if needed
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Product Image
                    _buildProductImage(),
                    const SizedBox(width: 16),

                    // Product Info
                    Expanded(
                      child: _buildProductInfo(),
                    ),

                    // Price and Actions
                    _buildPriceAndActions(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: item.image[0],
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) {
            return Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 32,
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Product Name
        Text(
          item.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),

        // Category or Additional Info
        if (item.category != null)
          Text(
            item.category,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
      ],
    );
  }

  Widget _buildPriceAndActions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Price
        Text(
          '${_formatCurrency(item.price)} VND',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),

        // Delete Button
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Colors.red[400],
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}
