import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubcategoryTileWidget extends StatelessWidget {
  const SubcategoryTileWidget({
    super.key,
    required this.image,
    required this.title,
  });
  final String image;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.grey,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(image, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 110,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
