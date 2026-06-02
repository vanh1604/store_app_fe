import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/core/services/address_service.dart';
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
  final AddressService _addressService = AddressService();
  bool _isLoading = false;

  late TextEditingController _fullNameController;
  late TextEditingController _addressController;
  late TextEditingController _numberController;

  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];

  String? _selectedProvinceName;
  String? _selectedDistrictName;
  String? _selectedWardName;

  int? _selectedProvinceCode;
  int? _selectedDistrictCode;

  bool _isLoadingProvinces = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _numberController = TextEditingController(text: user?.number ?? '');
    
    _selectedProvinceName = user?.province != "" ? user?.province : null;
    _selectedDistrictName = user?.district != "" ? user?.district : null;
    _selectedWardName = user?.ward != "" ? user?.ward : null;

    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    setState(() => _isLoadingProvinces = true);
    final data = await _addressService.getProvinces();
    setState(() {
      _provinces = data;
      _isLoadingProvinces = false;

      // Try to find the code for existing province name
      if (_selectedProvinceName != null) {
        final found = _provinces.firstWhere(
          (element) => element['name'] == _selectedProvinceName,
          orElse: () => null,
        );
        if (found != null) {
          _selectedProvinceCode = found['code'];
          _fetchDistricts(_selectedProvinceCode!);
        }
      }
    });
  }

  Future<void> _fetchDistricts(int provinceCode) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _wards = [];
    });
    final data = await _addressService.getDistricts(provinceCode);
    setState(() {
      _districts = data;
      _isLoadingDistricts = false;

      if (_selectedDistrictName != null) {
        final found = _districts.firstWhere(
          (element) => element['name'] == _selectedDistrictName,
          orElse: () => null,
        );
        if (found != null) {
          _selectedDistrictCode = found['code'];
          _fetchWards(_selectedDistrictCode!);
        }
      }
    });
  }

  Future<void> _fetchWards(int districtCode) async {
    setState(() {
      _isLoadingWards = true;
      _wards = [];
    });
    final data = await _addressService.getWards(districtCode);
    setState(() {
      _wards = data;
      _isLoadingWards = false;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
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
        province: _selectedProvinceName ?? '',
        district: _selectedDistrictName ?? '',
        ward: _selectedWardName ?? '',
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
        title: const Text('Chỉnh sửa hồ sơ'),
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
                label: 'Họ và tên',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên của bạn';
                  }
                  if (value.trim().length < 2) {
                    return 'Tên quá ngắn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Province Dropdown
              DropdownButtonFormField<int>(
                value: _selectedProvinceCode,
                isExpanded: true,
                menuMaxHeight: 300,
                decoration: InputDecoration(
                  labelText: 'Tỉnh/Thành phố',
                  prefixIcon: _isLoadingProvinces
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.map_outlined, color: Colors.purple),
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
                items: _provinces.map((province) {
                  return DropdownMenuItem<int>(
                    value: province['code'],
                    child: Text(province['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedProvinceCode = value;
                      _selectedProvinceName = _provinces.firstWhere(
                        (p) => p['code'] == value,
                      )['name'];
                      _selectedDistrictCode = null;
                      _selectedDistrictName = null;
                      _selectedWardName = null;
                      _districts = [];
                      _wards = [];
                    });
                    _fetchDistricts(value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Vui lòng chọn Tỉnh/Thành phố' : null,
              ),

              const SizedBox(height: 20),

              // District Dropdown
              DropdownButtonFormField<int>(
                value: _selectedDistrictCode,
                isExpanded: true,
                menuMaxHeight: 300,
                decoration: InputDecoration(
                  labelText: 'Quận/Huyện',
                  prefixIcon: _isLoadingDistricts
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.location_city_outlined, color: Colors.purple),
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
                items: _districts.map((district) {
                  return DropdownMenuItem<int>(
                    value: district['code'],
                    child: Text(district['name']),
                  );
                }).toList(),
                onChanged: _selectedProvinceCode == null
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDistrictCode = value;
                            _selectedDistrictName = _districts.firstWhere(
                              (d) => d['code'] == value,
                            )['name'];
                            _selectedWardName = null;
                            _wards = [];
                          });
                          _fetchWards(value);
                        }
                      },
                validator: (value) =>
                    value == null ? 'Vui lòng chọn Quận/Huyện' : null,
              ),

              const SizedBox(height: 20),

              // Ward Dropdown
              DropdownButtonFormField<String>(
                value: _selectedWardName,
                isExpanded: true,
                menuMaxHeight: 300,
                decoration: InputDecoration(
                  labelText: 'Phường/Xã',
                  prefixIcon: _isLoadingWards
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.home_work_outlined, color: Colors.purple),
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
                items: _wards.map((ward) {
                  return DropdownMenuItem<String>(
                    value: ward['name'] as String,
                    child: Text(ward['name']),
                  );
                }).toList(),
                onChanged: _selectedDistrictCode == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedWardName = value;
                        });
                      },
                validator: (value) =>
                    value == null ? 'Vui lòng chọn Phường/Xã' : null,
              ),

              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _addressController,
                label: 'Địa chỉ chi tiết (Số nhà, Tên đường)',
                icon: Icons.home_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập địa chỉ cụ thể';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _numberController,
                label: 'Số điện thoại',
                icon: Icons.phone_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (value.trim().length < 10) {
                    return 'Số điện thoại phải có ít nhất 10 chữ số';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'Vui lòng nhập số điện thoại hợp lệ';
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
                          'Lưu thay đổi',
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