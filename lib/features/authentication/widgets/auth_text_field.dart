import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ô nhập liệu dùng chung cho các màn xác thực (đăng nhập / đăng ký).
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData prefixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  static const Color _fill = Color(0xFFF4F6FA);
  static const Color _borderColor = Color(0xFFE4E7EC);
  static const Color _focusColor = Color(0xFF102DE1);
  static const Color _iconColor = Color(0xFF8A94A6);

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.getFont(
            'Nunito Sans',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.2,
            color: const Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: onChanged,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.getFont('Nunito Sans', fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: _fill,
            hintText: hint,
            hintStyle: GoogleFonts.getFont(
              'Nunito Sans',
              fontSize: 14,
              letterSpacing: 0.1,
              color: const Color(0xFF98A2B3),
            ),
            prefixIcon: Icon(prefixIcon, color: _iconColor),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: _border(_borderColor, 1),
            enabledBorder: _border(_borderColor, 1),
            focusedBorder: _border(_focusColor, 1.5),
            errorBorder: _border(const Color(0xFFD92D20), 1),
            focusedErrorBorder: _border(const Color(0xFFD92D20), 1.5),
          ),
        ),
      ],
    );
  }
}
