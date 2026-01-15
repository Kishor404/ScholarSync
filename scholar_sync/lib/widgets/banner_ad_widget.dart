// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter/foundation.dart';

// class BannerAdWidget extends StatefulWidget {
//   const BannerAdWidget({super.key});

//   @override
//   State<BannerAdWidget> createState() => _BannerAdWidgetState();
// }

// class _BannerAdWidgetState extends State<BannerAdWidget> {
//   BannerAd? _bannerAd;
//   bool _isLoaded = false;

//   @override
//   void initState() {
//     super.initState();

//     _bannerAd = BannerAd(
//       adUnitId: kReleaseMode
//           ? 'ca-app-pub-8743010172019780/8950466242' // ✅ YOUR REAL ID
//           : 'ca-app-pub-3940256099942544/6300978111', // ✅ TEST ID
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() => _isLoaded = true);
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           debugPrint('BannerAd failed: $error');
//         },
//       ),
//     );

//     _bannerAd!.load();
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoaded) return const SizedBox(height: 50);

//     return SizedBox(
//       width: _bannerAd!.size.width.toDouble(),
//       height: _bannerAd!.size.height.toDouble(),
//       child: AdWidget(ad: _bannerAd!),
//     );
//   }
// }
