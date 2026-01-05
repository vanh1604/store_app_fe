import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanh_store_app/models/banner.dart';

class BannerNotifier extends Notifier<List<BannerModel>> {
  @override
  List<BannerModel> build() {
    return [];
  }

  void setBanners(List<BannerModel> banners) {
    state = banners;
  }
}

final bannerProvider = NotifierProvider<BannerNotifier, List<BannerModel>>(() {
  return BannerNotifier();
});
