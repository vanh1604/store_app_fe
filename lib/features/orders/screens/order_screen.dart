import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/features/orders/controllers/order_controller.dart';
import 'package:vanh_store_app/features/authentication/providers/user_provider.dart';
import 'package:vanh_store_app/features/orders/screens/order_detail_screen.dart';
import 'package:vanh_store_app/features/orders/models/order.dart';
import 'package:vanh_store_app/core/utils/formatters.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final OrderController _orderController = OrderController();
  List<Order> _orders = [];
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = ref.read(userProvider);
    if (user != null) {
      try {
        final orders = await _orderController.loadOrders(buyerId: user.id);
        if (mounted) {
          setState(() {
            _orders = orders;
          });
        }
      } catch (e) {
        debugPrint("Lỗi khi tải đơn hàng: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isInitialLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed == true && mounted) {
      try {
        await _orderController.deleteOrder(orderId: orderId, context: context);
        _fetchOrders();
      } catch (e) {
        debugPrint("Lỗi khi xóa đơn hàng: $e");
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa đơn hàng', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: GoogleFonts.lato(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: GoogleFonts.lato(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orders;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header Section
          _buildHeader(orders.length),

          // Orders List
          Expanded(
            child: _isInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            return _OrderCard(
                              order: orders[index],
                              onDelete: () => _deleteOrder(orders[index].id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đơn hàng của tôi',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn có tổng cộng $count đơn hàng',
                style: GoogleFonts.lato(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có đơn hàng nào',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lịch sử đơn hàng của bạn sẽ xuất hiện ở đây',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onDelete;

  const _OrderCard({required this.order, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(),
                  const SizedBox(width: 16),
                  Expanded(child: _buildProductInfo()),
                ],
              ),
              const Divider(height: 24),
              _buildOrderFooter(),
            ],
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: order.image,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.productName,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF0B0C1E),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          order.category,
          style: GoogleFonts.lato(
            color: const Color(0xFF7F808C),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${formatCurrency(order.productPrice)} VND',
          style: GoogleFonts.lato(
            color: Colors.deepPurple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (order.orderedAt != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '${order.orderedAt!.day.toString().padLeft(2, '0')}/'
                '${order.orderedAt!.month.toString().padLeft(2, '0')}/'
                '${order.orderedAt!.year}  '
                '${order.orderedAt!.hour.toString().padLeft(2, '0')}:'
                '${order.orderedAt!.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.lato(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOrderFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusBadge(),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Xóa đơn hàng',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final String status;
    final Color color;

    if (order.delivered == true) {
      status = 'Đã giao hàng';
      color = const Color(0xFF3C55EF);
    } else if (order.processing == true) {
      status = 'Đang xử lý';
      color = Colors.purple;
    } else {
      status = 'Đã hủy';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
