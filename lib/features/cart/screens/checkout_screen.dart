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

      // Show loading indicator
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      // Calculate total amount from cart
      double totalAmount = 0;
      cartData.forEach((key, item) {
        totalAmount += item.price * item.quantity;
      });
      // Convert to cents for Stripe (amount should be in smallest currency unit)
      int amountInCents = (totalAmount * 100).toInt();

      // Stripe minimum amount is 50 cents
      if (amountInCents < 50) {
        amountInCents = 50;
      }

      print("DEBUG: Cart Items: ${cartProviderNotifier.getCartItems.length}");
      print("DEBUG: Total Amount: $totalAmount");
      print("DEBUG: Amount in Cents: $amountInCents");

      // Step 1: Create orders first with processing=false (pending payment)
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
          print("Order created with ID: $orderId");
        }
      }

      if (createdOrderIds.isEmpty) {
        throw Exception("Failed to create orders");
      }

      // Step 2: Create payment intent with first orderId and total amount
      print("Creating payment intent for amount: $amountInCents");
      final paymentIntentData = await orderController.createPaymentIntent(
        amount: amountInCents,
        currency: 'usd',
        orderId: createdOrderIds.first,
      );

      if (paymentIntentData['clientSecret'] == null) {
        throw Exception("Failed to get clientSecret from server");
      }

      // Step 3: Initialize payment sheet
      try {
        print("Initializing payment sheet...");
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData['clientSecret'],
            merchantDisplayName: 'Vanh Store',
            style: ThemeMode.light,
            applePay: const PaymentSheetApplePay(merchantCountryCode: 'VN'),
            googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: 'VN',
              testEnv: true,
            ),
          ),
        );
      } catch (e) {
        print("Error initializing payment sheet: $e");
        throw Exception("Stripe initialization failed: $e");
      }

      // Hide loading BEFORE presenting payment sheet
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Step 4: Present payment sheet
      try {
        print("Presenting payment sheet...");
        await Stripe.instance.presentPaymentSheet();
        print("Payment sheet presented and completed.");
      } catch (e) {
        print("Error presenting payment sheet: $e");
        rethrow; // Re-throw to be caught by StripeException or catch-all
      }

      // Show loading again for order updates
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      // Step 5: Payment successful! Update all orders to processing=true
      for (String orderId in createdOrderIds) {
        await orderController.updateOrderProcessing(
          orderId: orderId,
          processing: true,
          context: context,
        );
      }

      // Clear cart after successful payment
      cartProviderNotifier.clearCart();

      // Close loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (!context.mounted) return;
      showSnackBar(context, 'Payment successful! Order placed successfully');

      // Navigate to main screen
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } on StripeException catch (e) {
      // Payment failed or cancelled - delete created orders
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      for (String orderId in createdOrderIds) {
        try {
          await orderController.deleteOrder(orderId: orderId, context: context);
        } catch (deleteError) {
          print("Failed to delete order $orderId: $deleteError");
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      print("Stripe error: ${e.error.localizedMessage}");
      if (!context.mounted) return;
      showSnackBar(
        context,
        'Payment cancelled or failed: ${e.error.localizedMessage ?? "Unknown Stripe error"}',
      );
    } catch (e) {
      // Error occurred - delete created orders
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      print("Error occurred. Deleting created orders...");
      for (String orderId in createdOrderIds) {
        try {
          await orderController.deleteOrder(orderId: orderId, context: context);
          print("Deleted order: $orderId");
        } catch (deleteError) {
          print("Failed to delete order $orderId: $deleteError");
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      print("Error: $e");
      if (!context.mounted) return;
      showSnackBar(context, 'An error occurred: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartData = ref.watch(cartProvider);
    final cartProviderNotifier = ref.read(cartProvider.notifier);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Center(
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
                child: SizedBox(
                  width: 335,
                  height: 74,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 335,
                          height: 74,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFEFF0F2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 70,
                        top: 17,
                        child: SizedBox(
                          width: 215,
                          height: 41,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -1,
                                left: -1,
                                child: SizedBox(
                                  width: 219,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: SizedBox(
                                          width: 114,
                                          child: user!.province.isNotEmpty
                                              ? Text(
                                                  'Address',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.1,
                                                  ),
                                                )
                                              : Text(
                                                  'Address added',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.1,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: user.address.isNotEmpty
                                            ? Text(
                                                '${user.address}, ${user.ward}',
                                                style: GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.3,
                                                ),
                                              )
                                            : Text(
                                                'No address added',
                                                style: GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.3,
                                                ),
                                              ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: user.district.isNotEmpty
                                            ? Text(
                                                '${user.district}, ${user.province}',
                                                style: GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.3,
                                                ),
                                              )
                                            : Text(
                                                'No city added',
                                                style: GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.3,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 16,
                        child: SizedBox.square(
                          dimension: 42,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 43,
                                  height: 43,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBF7F5),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      Positioned(
                                        left: 11,
                                        top: 11,
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 305,
                        top: 25,
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F6ce18a0efc6e889de2f2878027c689c9caa53feeedit%201.png?alt=media&token=a3a8a999-80d5-4a2e-a9b7-a43a7fa8789a',
                          width: 20,
                          height: 20,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your Items',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: cartData.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final cartItem = cartData.values.toList()[index];
                    return InkWell(
                      child: Container(
                        width: 336,
                        height: 91,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Color(0xFFEFF0F2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 6,
                              top: 6,
                              child: SizedBox(
                                width: 311,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 78,
                                      height: 78,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFBCC5FF),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: cartItem.image[0],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 11),
                                    Expanded(
                                      child: Container(
                                        height: 78,
                                        alignment: Alignment(0, -0.51),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  cartItem.productName,
                                                  style: GoogleFonts.quicksand(
                                                    letterSpacing: 1.2,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  cartItem.category,
                                                  style: GoogleFonts.lato(
                                                    color: Colors.blueGrey,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      "\$${cartItem.price.toStringAsFixed(2)}",
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
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Choose Payment Method',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RadioListTile<String>(
                title: Text(
                  'Stripe',
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
                  'Cash on Delivery',
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
                        return ShippingAddressScreen();
                      },
                    ),
                  );
                },
                child: Text(
                  'Please Enter Shipping Address',
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
                            showSnackBar(context, 'Order placed successfully');
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
                    color: _isLoading ? Colors.grey : Color(0xFF3854EE),
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
                                ? 'Pay Now'
                                : 'Place Order',
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
