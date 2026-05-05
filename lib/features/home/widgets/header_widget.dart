import 'package:flutter/material.dart';
import 'package:vanh_store_app/features/products/screens/search_screen.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/icons/searchBanner.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Image.asset('assets/icons/searc1.png', width: 22, height: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'What are you looking for?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F7F7F),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Image.asset('assets/icons/cam.png', width: 22, height: 22),
                        const SizedBox(width: 14),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildIconButton('assets/icons/bell.png', () {}),
              const SizedBox(width: 12),
              _buildIconButton('assets/icons/message.png', () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(assetPath, width: 22, height: 22),
      ),
    );
  }
}
