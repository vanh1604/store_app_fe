import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/controllers/banner_controller.dart';
import 'package:vanh_store_app/models/banner.dart';
import 'package:vanh_store_app/provider/banner_provider.dart';

class BannerWidget extends ConsumerStatefulWidget {
  const BannerWidget({super.key});

  @override
  ConsumerState<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends ConsumerState<BannerWidget> {
  late Future<List<BannerModel>> _bannersFuture;

  @override
  void initState() {
    super.initState();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    final bannerController = BannerController();
    try {
      final banners = await bannerController.loadBanners();
      ref.read(bannerProvider.notifier).setBanners(banners);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final banners = ref.watch(bannerProvider);
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
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.network(banners[index].image, fit: BoxFit.cover),
            );
          },
        ),
      ),
    );
  }
}
