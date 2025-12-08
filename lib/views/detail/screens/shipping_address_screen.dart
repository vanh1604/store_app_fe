import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
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
                  decoration: InputDecoration(labelText: 'State'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your state';
                    }
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(labelText: 'City'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(labelText: 'locality'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your locality';
                    }
                  },
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
          onTap: () {
            if (_formKey.currentState!.validate()) {
              print('valid');
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
