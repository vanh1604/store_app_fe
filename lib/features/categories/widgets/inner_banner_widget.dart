import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class InnerBannerWidget extends StatelessWidget {
  const InnerBannerWidget({super.key, required this.imageUrl});
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
        ),
      ),
    );
  }
}
