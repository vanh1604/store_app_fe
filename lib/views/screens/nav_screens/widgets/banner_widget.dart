import 'package:flutter/material.dart';
import 'package:vanh_store_app/controllers/banner_controller.dart';
import 'package:vanh_store_app/models/banner.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  late Future<List<BannerModel>> _bannersFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bannersFuture = BannerController().loadBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 170,
        decoration: BoxDecoration(
          color: Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FutureBuilder(
          future: _bannersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No banners available"));
            } else {
              List<BannerModel> banners = snapshot.data!;
              return PageView.builder(
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Image.network(
                      banners[index].image,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
