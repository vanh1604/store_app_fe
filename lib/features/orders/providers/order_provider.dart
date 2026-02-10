import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/features/orders/models/order.dart';

class OrderNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    return [];
  }

  void setOrders(List<Order> orders) {
    state = orders;
  }
}

final orderProvider = NotifierProvider<OrderNotifier, List<Order>>(() {
  return OrderNotifier();
});
