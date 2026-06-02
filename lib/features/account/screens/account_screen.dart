import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/features/authentication/controllers/auth_controller.dart';
import 'package:vanh_store_app/features/authentication/providers/user_provider.dart';
import 'package:vanh_store_app/features/account/screens/edit_profile_screen.dart';
import 'package:vanh_store_app/features/orders/screens/order_screen.dart';
import 'package:vanh_store_app/features/orders/screens/shipping_address_screen.dart';

class AccountScreen extends ConsumerWidget {
  AccountScreen({super.key});
  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tài khoản',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade700,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user?.fullName.isNotEmpty == true
                            ? user!.fullName[0].toUpperCase()
                            : 'N',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Full Name
                  Text(
                    user?.fullName ?? 'Người dùng',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Email
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  // Address
                  if (user?.ward.isNotEmpty == true ||
                      user?.district.isNotEmpty == true ||
                      user?.province.isNotEmpty == true ||
                      user?.address.isNotEmpty == true)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            [
                              user?.address,
                              user?.ward,
                              user?.district,
                              user?.province,
                            ].where((e) => e?.isNotEmpty == true).join(', '),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Menu Items
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Đơn hàng của tôi',
                    subtitle: 'Xem lịch sử đơn hàng',
                    iconColor: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Chỉnh sửa hồ sơ',
                    subtitle: 'Cập nhật thông tin cá nhân',
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildMenuItem(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Địa chỉ giao hàng',
                    subtitle: 'Quản lý địa chỉ giao hàng',
                    iconColor: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShippingAddressScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt',
                    subtitle: 'Tùy chọn ứng dụng và thông báo',
                    iconColor: Colors.grey.shade700,
                    onTap: () {
                      // TODO: Navigate to Settings screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cài đặt - Sắp ra mắt'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Trợ giúp & Hỗ trợ',
                    subtitle: 'Nhận trợ giúp và liên hệ hỗ trợ',
                    iconColor: Colors.teal,
                    onTap: () {
                      // TODO: Navigate to Help screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Trợ giúp & Hỗ trợ - Sắp ra mắt'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'Giới thiệu',
                    subtitle: 'Phiên bản ứng dụng và thông tin',
                    iconColor: Colors.indigo,
                    onTap: () {
                      // TODO: Navigate to About screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Giới thiệu - Sắp ra mắt'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Đăng xuất'),
                        content: const Text(
                          'Bạn có chắc chắn muốn đăng xuất không?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );

                    if (shouldSignOut == true && context.mounted) {
                      await authController.signOutUser(context: context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200, width: 1),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Delete Account Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Show confirmation dialog with stronger warning
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.red.shade700,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            const Text('Xóa tài khoản'),
                          ],
                        ),
                        content: const Text(
                          'Bạn có chắc chắn muốn xóa tài khoản không? Hành động này không thể hoàn tác và tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
                          style: TextStyle(fontSize: 14),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              backgroundColor: Colors.red.shade50,
                            ),
                            child: const Text(
                              'Xóa',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (shouldDelete == true && context.mounted) {
                      if (user?.id != null) {
                        await authController.deleteAccount(
                          context: context,
                          id: user!.id,
                          ref: ref,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_forever),
                      SizedBox(width: 8),
                      Text(
                        'Xóa tài khoản',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}
