import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/features/authentication/controllers/auth_controller.dart';
import 'package:vanh_store_app/features/authentication/providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  late TextEditingController _fullNameController;
  late TextEditingController _provinceController;
  late TextEditingController _districtController;
  late TextEditingController _wardController;
  late TextEditingController _addressController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _provinceController = TextEditingController(text: user?.province ?? '');
    _districtController = TextEditingController(text: user?.district ?? '');
    _wardController = TextEditingController(text: user?.ward ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _numberController = TextEditingController(text: user?.number ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = ref.read(userProvider);

      await _authController.updateUserProfile(
        context: context,
        id: user!.id,
        fullName: _fullNameController.text.trim(),
        province: _provinceController.text.trim(),
        district: _districtController.text.trim(),
        ward: _wardController.text.trim(),
        address: _addressController.text.trim(),
        number: _numberController.text.trim(),
        ref: ref,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _provinceController,
                label: 'Tỉnh/Thành phố (Province/City)',
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _districtController,
                label: 'Quận/Huyện (District)',
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _wardController,
                label: 'Phường/Xã (Ward)',
                icon: Icons.home_work_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _addressController,
                label: 'Số nhà, Tên đường (Address)',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _numberController,
                label: 'Số điện thoại (Phone Number)',
                icon: Icons.phone_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.purple),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }
}