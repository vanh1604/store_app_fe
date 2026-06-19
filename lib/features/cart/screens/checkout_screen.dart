import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/features/orders/controllers/order_controller.dart';
import 'package:vanh_store_app/features/cart/providers/cart_provider.dart';
import 'package:vanh_store_app/features/authentication/providers/user_provider.dart';
import 'package:vanh_store_app/core/services/http_response_handler.dart';
import 'package:vanh_store_app/features/orders/screens/shipping_address_screen.dart';
import 'package:vanh_store_app/features/home/screens/main_screen.dart';
import 'package:vanh_store_app/core/utils/formatters.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String selectedPaymentMethod = 'stripe';
  bool _isLoading = false;
  final OrderController orderController = OrderController();

  Future<void> handleStripePayment(BuildContext context) async {
    List<String> createdOrderIds = [];

    try {
      final cartData = ref.read(cartProvider);
      final cartProviderNotifier = ref.read(cartProvider.notifier);
      final user = ref.read(userProvider);

      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      double totalAmount = 0;
      cartData.forEach((key, item) {
        totalAmount += item.price * item.quantity;
      });
      int amount = totalAmount.toInt();

      for (var entry in cartProviderNotifier.getCartItems.entries) {
        var item = entry.value;
        final orderId = await orderController.uploadOrders(
          id: '',
          fullName: user!.fullName,
          email: user.email,
          province: user.province,
          district: user.district,
          ward: user.ward,
          address: user.address,
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          productPrice: item.price,
          category: item.category,
          image: item.image[0],
          buyerId: user.id,
          vendorId: item.vendorId,
          processing: false,
          delivered: false,
          selectedSize: item.selectedSize,
          variantId: item.variantId,
          context: context,
        );

        if (orderId != null) {
          createdOrderIds.add(orderId);
        }
      }

      if (createdOrderIds.isEmpty) {
        throw Exception("Không thể tạo đơn hàng");
      }

      final paymentIntentData = await orderController.createPaymentIntent(
        amount: amount,
        currency: 'vnd',
        orderId: createdOrderIds.first,
      );

      if (paymentIntentData['clientSecret'] == null) {
        throw Exception("Không thể nhận mã bảo mật từ máy chủ");
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          merchantDisplayName: 'Vanh Store',
          style: ThemeMode.light,
          returnURL: 'vanhstore://redirect',
          // Apple Pay tạm tắt: merchant ID chưa được provision trong Apple Developer
          // nên khi bật sẽ khiến PaymentSheet không hiện trên iOS. Bật lại khi đã có
          // merchant ID thật và cấu hình Xcode.
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'VN',
            testEnv: true,
          ),
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      await Stripe.instance.presentPaymentSheet();

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      for (String orderId in createdOrderIds) {
        await orderController.updateOrderProcessing(
          orderId: orderId,
          processing: true,
          context: context,
        );
      }

      cartProviderNotifier.clearCart();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (!context.mounted) return;
      showSnackBar(context, 'Thanh toán thành công! Đơn hàng đã được đặt');

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } on StripeException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      for (String orderId in createdOrderIds) {
        try {
          await orderController.deleteOrder(orderId: orderId, context: context);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (!context.mounted) return;
      showSnackBar(
        context,
        'Thanh toán bị hủy hoặc thất bại: ${e.error.localizedMessage ?? "Lỗi thẻ"}',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      for (String orderId in createdOrderIds) {
        try {
          await orderController.deleteOrder(orderId: orderId, context: context);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (!context.mounted) return;
      showSnackBar(context, 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartData = ref.watch(cartProvider);
    final cartProviderNotifier = ref.read(cartProvider.notifier);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShippingAddressScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFEFF0F2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF7F5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://storage.googleapis.com/codeless-dev.appspot.com/uploads%2Fimages%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F2ee3a5ce3b02828d0e2806584a6baa88.png',
                            height: 26,
                            width: 26,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user!.province.isNotEmpty
                                  ? 'Địa chỉ'
                                  : 'Đã thêm địa chỉ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.address.isNotEmpty
                                  ? '${user.address}, ${user.ward}'
                                  : 'Chưa có địa chỉ',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.3,
                              ),
                            ),
                            Text(
                              user.district.isNotEmpty
                                  ? '${user.district}, ${user.province}'
                                  : 'Chưa có tỉnh/thành phố',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F6ce18a0efc6e889de2f2878027c689c9caa53feeedit%201.png?alt=media&token=a3a8a999-80d5-4a2e-a9b7-a43a7fa8789a',
                        width: 20,
                        height: 20,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sản phẩm của bạn',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                itemCount: cartData.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final cartItem = cartData.values.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEFF0F2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: const Color(0xFFBCC5FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: cartItem.image[0],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItem.productName,
                                  style: GoogleFonts.quicksand(
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cartItem.category,
                                  style: GoogleFonts.lato(
                                    color: Colors.blueGrey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${formatCurrency(cartItem.price)} VND",
                                  style: GoogleFonts.robotoSerif(
                                    fontSize: 14,
                                    color: Colors.pink,
                                    letterSpacing: 1.3,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                'Chọn phương thức thanh toán',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RadioListTile<String>(
                title: Text(
                  'Thẻ (Stripe)',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                value: 'stripe',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),
              RadioListTile(
                title: Text(
                  'Thanh toán khi nhận hàng',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                value: 'cashOnDelivery',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: user.district.isEmpty
            ? TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ShippingAddressScreen();
                      },
                    ),
                  );
                },
                child: Text(
                  'Vui lòng nhập địa chỉ giao hàng',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.7,
                    fontSize: 17,
                  ),
                ),
              )
            : InkWell(
                onTap: _isLoading
                    ? null
                    : () async {
                        if (selectedPaymentMethod == "stripe") {
                          await handleStripePayment(context);
                        } else {
                          await Future.forEach(
                            cartProviderNotifier.getCartItems.entries,
                            (entry) {
                              var item = entry.value;
                              orderController.uploadOrders(
                                id: '',
                                fullName: ref.read(userProvider)!.fullName,
                                email: ref.read(userProvider)!.email,
                                province: ref.read(userProvider)!.province,
                                district: ref.read(userProvider)!.district,
                                ward: ref.read(userProvider)!.ward,
                                address: ref.read(userProvider)!.address,
                                productId: item.productId,
                                productName: item.productName,
                                quantity: item.quantity,
                                productPrice: item.price,
                                category: item.category,
                                image: item.image[0],
                                buyerId: ref.read(userProvider)!.id,
                                vendorId: item.vendorId,
                                processing: true,
                                delivered: false,
                                context: context,
                                selectedSize: item.selectedSize,
                                variantId: item.variantId,
                              );
                            },
                          ).then((value) {
                            cartProviderNotifier.clearCart();
                            showSnackBar(context, 'Đặt hàng thành công');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return MainScreen();
                                },
                              ),
                            );
                          });
                        }
                      },
                child: Container(
                  width: 338,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey : const Color(0xFF3854EE),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            selectedPaymentMethod == "stripe"
                                ? 'Thanh toán ngay'
                                : 'Đặt hàng',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ),
      ),
    );
  }
}
