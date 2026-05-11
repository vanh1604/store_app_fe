import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/features/authentication/controllers/auth_controller.dart';
import 'package:vanh_store_app/features/authentication/providers/user_provider.dart';

class ShippingAddressScreen extends ConsumerStatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends ConsumerState<ShippingAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  late TextEditingController _provinceController;
  late TextEditingController _districtController;
  late TextEditingController _wardController;
  late TextEditingController _addressController;
  void _showloadingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Updating Address..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    final user = ref.read(userProvider);
    _provinceController = TextEditingController(text: user?.province ?? "");
    _districtController = TextEditingController(text: user?.district ?? "");
    _wardController = TextEditingController(text: user?.ward ?? "");
    _addressController = TextEditingController(text: user?.address ?? "");
  }

  @override
  void dispose() {
    _addressController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final updateUser = ref.read(userProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.96),
        elevation: 0,
        title: Text(
          'Delivery Address',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Where will your \n be shipped to?',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Tỉnh/Thành phố (Province/City)',
                  ),
                  controller: _provinceController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your province';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quận/Huyện (District)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your district';
                    }
                    return null;
                  },
                  controller: _districtController,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phường/Xã (Ward)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ward';
                    }
                    return null;
                  },
                  controller: _wardController,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Số nhà, Tên đường (Address)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                  controller: _addressController,
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: InkWell(
          onTap: () async {
            _showloadingDialog();
            if (_formKey.currentState!.validate()) {
              final user = ref.read(userProvider);
              if (user == null || user.id.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Lỗi: Không tìm thấy thông tin User. Hãy đăng nhập lại.",
                    ),
                  ),
                );
                return;
              }
              await _authController
                  .updateUserLocation(
                    ref: ref,
                    context: context,
                    id: user.id,
                    province: _provinceController.text,
                    district: _districtController.text,
                    ward: _wardController.text,
                    address: _addressController.text,
                  )
                  .whenComplete(() {
                    updateUser.updateUser(
                      province: _provinceController.text,
                      district: _districtController.text,
                      ward: _wardController.text,
                      address: _addressController.text,
                    );
                    Navigator.of(context).pop(); // Close loading dialog
                    Navigator.pop(context);
                  });
            } else {
              print("not valid");
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Save Address',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
