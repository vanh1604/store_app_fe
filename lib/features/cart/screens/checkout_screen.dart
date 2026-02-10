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
  final OrderController orderController = OrderController();
  Future<void> handleStripePayment(BuildContext context) async {
    List<String> createdOrderIds = [];

    try {
      final cartData = ref.read(cartProvider);
      final cartProviderNotifier = ref.read(cartProvider.notifier);
      final user = ref.read(userProvider);

      // Show loading indicator
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Calculate total amount from cart
      double totalAmount = 0;
      cartData.forEach((key, item) {
        totalAmount += item.price * item.quantity;
      });
      // Convert to cents for Stripe (amount should be in smallest currency unit)
      int amountInCents = (totalAmount * 100).toInt();
      // Step 1: Create orders first with processing=false (pending payment)
      for (var entry in cartProviderNotifier.getCartItems.entries) {
        var item = entry.value;
        final orderId = await orderController.uploadOrders(
          id: '',
          fullName: user!.fullName,
          email: user.email,
          state: user.state,
          city: user.city,
          locality: user.locality,
          productName: item.productName,
          quantity: item.quantity,
          productPrice: item.price,
          category: item.category,
          image: item.image[0],
          buyerId: user.id,
          vendorId: item.vendorId,
          processing: false,
          delivered: false,
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

      // Step 2: Create payment intent with first orderId
      final paymentIntentData = await orderController.createPaymentIntent(
        amount: amountInCents,
        currency: 'usd',
        orderId: createdOrderIds.first,
      );

      // Step 3: Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          merchantDisplayName: 'Vanh Store',
          style: ThemeMode.light,
        ),
      );

      // Step 4: Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 5: Payment successful!

      // Clear cart after successful payment
      cartProviderNotifier.clearCart();

      // Close loading dialog
      if (!context.mounted) return;
      Navigator.pop(context);

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

      for (String orderId in createdOrderIds) {
        try {
          await orderController.deleteOrder(orderId: orderId, context: context);
        } catch (deleteError) {
          print("Failed to delete order $orderId: $deleteError");
        }
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      print("Stripe error: ${e.error.localizedMessage}");
      if (!context.mounted) return;
      showSnackBar(
        context,
        'Payment cancelled or failed: ${e.error.localizedMessage}',
      );
    } catch (e) {
      // Error occurred - delete created orders
      print("Error occurred. Deleting created orders...");
      for (String orderId in createdOrderIds) {
        try {
          await orderController.deleteOrder(orderId: orderId, context: context);
          print("Deleted order: $orderId");
        } catch (deleteError) {
          print("Failed to delete order $orderId: $deleteError");
        }
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
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
                                          child: user!.state.isNotEmpty
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
                                        child: user.state.isNotEmpty
                                            ? Text(
                                                user.state,
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
                                        child: user.city.isNotEmpty
                                            ? Text(
                                                user.city,
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
                                        child: Image.network(
                                          height: 26,
                                          width: 26,
                                          'https://storage.googleapis.com/codeless-dev.appspot.com/uploads%2Fimages%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F2ee3a5ce3b02828d0e2806584a6baa88.png',
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
                        child: Image.network(
                          width: 20,
                          height: 20,
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F6ce18a0efc6e889de2f2878027c689c9caa53feeedit%201.png?alt=media&token=a3a8a999-80d5-4a2e-a9b7-a43a7fa8789a',
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
                                      child: Image.network(cartItem.image[0]),
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
        child: user.state.isEmpty
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
                onTap: () async {
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
                          state: ref.read(userProvider)!.state,
                          city: ref.read(userProvider)!.city,
                          locality: ref.read(userProvider)!.locality,
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
                    color: Color(0xFF3854EE),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Center(
                    child: Text(
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
