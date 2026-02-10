import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/features/vendors/models/vendor.dart';

class VendorProvider extends Notifier<List<Vendor>> {
  @override
  List<Vendor> build() {
    return [];
  }

  void setVendors(List<Vendor> vendors) {
    state = vendors;
  }
}

final vendorProvider = NotifierProvider<VendorProvider, List<Vendor>>(() {
  return VendorProvider();
});
