import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/controllers/order_controller.dart';
import 'package:vanh_store_app/provider/order_provider.dart';
import 'package:vanh_store_app/provider/user_provider.dart';
import 'package:vanh_store_app/views/detail/screens/order_detail_screen.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  Future<void> _fetchOrderData() async {
    final user = ref.read(userProvider);
    if (user != null) {
      final OrderController orderController = OrderController();
      try {
        final res = await orderController.loadOrders(buyerId: user.id);
        ref.read(orderProvider.notifier).setOrders(res);
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  Future<void> deleteOrder({required String orderId}) async {
    try {
      final OrderController orderController = OrderController();
      await orderController.deleteOrder(orderId: orderId, context: context);
      _fetchOrderData();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchOrderData();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.2,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 118,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/cartb.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 322,
                top: 52,
                child: Stack(
                  children: [
                    Image.asset('assets/icons/not.png', width: 25, height: 25),
                    Positioned(
                      top: 0,
                      right: 0,

                      child: Container(
                        width: 20,
                        height: 20,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade800,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            orders.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 61,
                top: 51,
                child: Text(
                  'My Orders',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: orders.isEmpty
          ? Center(child: Text('No orders found'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 25,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return OrderDetailScreen(order: order);
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: 335,
                      height: 153,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: SizedBox(
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 336,
                                height: 154,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Color(0xFFEFF0F2)),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 13,
                                      top: 9,
                                      child: Container(
                                        width: 78,
                                        height: 78,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color(0xFFEFF0F2),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              left: 10,
                                              top: 5,
                                              child: Image.network(
                                                order.image,
                                                width: 58,
                                                height: 67,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 101,
                                      top: 14,
                                      child: SizedBox(
                                        width: 216,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: Text(
                                                        order.productName,
                                                        style:
                                                            GoogleFonts.montserrat(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 16,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        order.category,
                                                        style:
                                                            GoogleFonts.montserrat(
                                                              color: Color(
                                                                0XFF7F808C,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "\$${order.productPrice.toStringAsFixed(2)}",
                                                      style:
                                                          GoogleFonts.montserrat(
                                                            color: Color(
                                                              0XFF0B0C1E,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
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
                                      left: 13,
                                      top: 113,
                                      child: Container(
                                        width: 97,
                                        height: 25,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: order.delivered == true
                                              ? Color(0xFF3C55EF)
                                              : order.processing == true
                                              ? Colors.purple
                                              : Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              left: 9,
                                              top: 2,
                                              child: Text(
                                                order.delivered == true
                                                    ? "Delivered"
                                                    : order.processing == true
                                                    ? "Processing"
                                                    : "Cancelled",
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 298,
                                      top: 115,
                                      child: InkWell(
                                        onTap: () {
                                          deleteOrder(orderId: order.id);
                                        },
                                        child: Image.asset(
                                          'assets/icons/delete.png',
                                          width: 20,
                                          height: 20,
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
                  ),
                );
              },
            ),
    );
  }
}
