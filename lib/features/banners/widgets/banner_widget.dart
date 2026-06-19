import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vanh_store_app/features/banners/controllers/banner_controller.dart';
import 'package:vanh_store_app/features/banners/models/banner.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  List<BannerModel> _banners = [];

  @override
  void initState() {
    super.initState();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    final bannerController = BannerController();
    try {
      final banners = await bannerController.loadBanners();
      if (mounted) {
        setState(() {
          _banners = banners;
        });
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final banners = _banners;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 170,
        decoration: BoxDecoration(
          color: Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: PageView.builder(
          itemCount: banners.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              key: ValueKey(banners[index].id),
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: banners[index].image,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
              ),
            );
          },
        ),
      ),
    );
  }
}
