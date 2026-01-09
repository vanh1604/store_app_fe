import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/controllers/order_controller.dart';
import 'package:vanh_store_app/models/order.dart';
import 'package:vanh_store_app/provider/order_provider.dart';
import 'package:vanh_store_app/provider/user_provider.dart';
import 'package:vanh_store_app/views/detail/screens/order_detail_screen.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    setState(() => _isLoading = true);
    final user = ref.read(userProvider);
    if (user != null) {
      final OrderController orderController = OrderController();
      try {
        final res = await orderController.loadOrders(buyerId: user.id);
        ref.read(orderProvider.notifier).setOrders(res);
      } catch (e) {
        debugPrint("Error fetching orders: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteOrder(String orderId) async {
    final confirm = await _showDeleteConfirmation();
    if (!confirm || !mounted) return;

    try {
      final OrderController orderController = OrderController();
      await orderController.deleteOrder(orderId: orderId, context: context);
      await _fetchOrderData();
    } catch (e) {
      debugPrint("Error deleting order: $e");
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Order', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this order?', style: GoogleFonts.lato()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.lato(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.lato(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(orders.length),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? _buildEmptyState()
              : _buildOrderList(orders),
    );
  }

  PreferredSizeWidget _buildAppBar(int orderCount) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/cartb.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Orders',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildNotificationBadge(orderCount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.asset('assets/icons/not.png', width: 28, height: 28),
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.yellow.shade800,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
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
            'No Orders Yet',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    return RefreshIndicator(
      onRefresh: _fetchOrderData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _OrderCard(
            order: orders[index],
            onTap: () => _navigateToOrderDetail(orders[index]),
            onDelete: () => _deleteOrder(orders[index].id),
          );
        },
      ),
    );
  }

  void _navigateToOrderDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(order: order),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 12),
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
        child: Image.network(
          order.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
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
          '\$${order.productPrice.toStringAsFixed(2)}',
          style: GoogleFonts.lato(
            color: Colors.deepPurple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          tooltip: 'Delete order',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final String status;
    final Color color;

    if (order.delivered == true) {
      status = 'Delivered';
      color = const Color(0xFF3C55EF);
    } else if (order.processing == true) {
      status = 'Processing';
      color = Colors.purple;
    } else {
      status = 'Cancelled';
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
