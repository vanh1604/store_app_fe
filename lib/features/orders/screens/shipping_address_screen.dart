import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanh_store_app/core/services/address_service.dart';
import 'package:vanh_store_app/features/authentication/controllers/auth_controller.dart';
import 'package:vanh_store_app/features/authentication/providers/user_provider.dart';

class ShippingAddressScreen extends ConsumerStatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  ConsumerState<ShippingAddressScreen> createState() =>
      _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends ConsumerState<ShippingAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AddressService _addressService = AddressService();
  final AuthController _authController = AuthController();
  final TextEditingController _addressController = TextEditingController();

  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];

  int? _selectedProvinceCode;
  int? _selectedDistrictCode;
  String? _selectedWardName;

  String? _selectedProvinceName;
  String? _selectedDistrictName;

  bool _isLoadingProvinces = true;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
    _loadCurrentAddress();
  }

  void _loadCurrentAddress() {
    final user = ref.read(userProvider);
    if (user != null) {
      _addressController.text = user.address;
      _selectedProvinceName = user.province;
      _selectedDistrictName = user.district;
      _selectedWardName = user.ward;
    }
  }

  Future<void> _fetchProvinces() async {
    try {
      final provinces = await _addressService.getProvinces();
      setState(() {
        _provinces = provinces;
        _isLoadingProvinces = false;
      });

      if (_selectedProvinceName != null && _selectedProvinceName!.isNotEmpty) {
        final found = _provinces.firstWhere(
          (element) => element['name'] == _selectedProvinceName,
          orElse: () => null,
        );
        if (found != null) {
          _selectedProvinceCode = found['code'];
          await _fetchDistricts(_selectedProvinceCode!);
        }
      }
    } catch (e) {
      setState(() => _isLoadingProvinces = false);
    }
  }

  Future<void> _fetchDistricts(int provinceCode) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _wards = [];
    });
    try {
      final districts = await _addressService.getDistricts(provinceCode);
      setState(() {
        _districts = districts;
        _isLoadingDistricts = false;
      });

      if (_selectedDistrictName != null && _selectedDistrictName!.isNotEmpty) {
        final found = _districts.firstWhere(
          (element) => element['name'] == _selectedDistrictName,
          orElse: () => null,
        );
        if (found != null) {
          _selectedDistrictCode = found['code'];
          await _fetchWards(_selectedDistrictCode!);
        }
      }
    } catch (e) {
      setState(() => _isLoadingDistricts = false);
    }
  }

  Future<void> _fetchWards(int districtCode) async {
    setState(() {
      _isLoadingWards = true;
      _wards = [];
    });
    try {
      final wards = await _addressService.getWards(districtCode);
      setState(() {
        _wards = wards;
        _isLoadingWards = false;
      });
    } catch (e) {
      setState(() => _isLoadingWards = false);
    }
  }

  void _showloadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Đang cập nhật địa chỉ..."),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final updateUser = ref.read(userProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.96),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.96),
        elevation: 0,
        title: Text(
          'Địa chỉ giao hàng',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Đơn hàng của bạn sẽ được\ngiao đến đâu?',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Province Dropdown
                DropdownButtonFormField<int>(
                  initialValue: _selectedProvinceCode,
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
                        : null,
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
                      });
                      _fetchDistricts(value);
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn Tỉnh/Thành phố' : null,
                ),

                const SizedBox(height: 15),

                // District Dropdown
                DropdownButtonFormField<int>(
                  initialValue: _selectedDistrictCode,
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
                        : null,
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
                            });
                            _fetchWards(value);
                          }
                        },
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn Quận/Huyện' : null,
                ),

                const SizedBox(height: 15),

                // Ward Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedWardName,
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
                        : null,
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

                const SizedBox(height: 15),

                // Address Text Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ chi tiết (Số nhà, Tên đường)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa chỉ của bạn';
                    }
                    return null;
                  },
                  controller: _addressController,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: InkWell(
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              _showloadingDialog();
              final user = ref.read(userProvider);
              if (user == null || user.id.isEmpty) {
                Navigator.pop(context); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Lỗi: Không tìm thấy thông tin User. Hãy đăng nhập lại.",
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
                return;
              }
              await _authController
                  .updateUserLocation(
                    ref: ref,
                    context: context,
                    id: user.id,
                    province: _selectedProvinceName!,
                    district: _selectedDistrictName!,
                    ward: _selectedWardName!,
                    address: _addressController.text,
                  )
                  .whenComplete(() {
                    updateUser.updateUser(
                      province: _selectedProvinceName!,
                      district: _selectedDistrictName!,
                      ward: _selectedWardName!,
                      address: _addressController.text,
                    );
                    Navigator.of(context).pop(); // Close loading dialog
                    Navigator.pop(context);
                  });
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
                'Lưu địa chỉ',
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
