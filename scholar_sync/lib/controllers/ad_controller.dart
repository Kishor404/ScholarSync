// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter/foundation.dart';

// class AdController extends GetxController {
//   InterstitialAd? _interstitialAd;
//   RewardedAd? _rewardedAd;

//   final _isInterstitialReady = false.obs;
//   final _isRewardedReady = false.obs;

//   // ---------------- LOAD ADS ----------------

//   void loadInterstitial() {
//     InterstitialAd.load(
//       adUnitId: kReleaseMode
//           ? 'YOUR_INTERSTITIAL_AD_UNIT_ID'
//           : 'ca-app-pub-3940256099942544/1033173712', // TEST
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (ad) {
//           _interstitialAd = ad;
//           _isInterstitialReady.value = true;
//         },
//         onAdFailedToLoad: (error) {
//           _isInterstitialReady.value = false;
//         },
//       ),
//     );
//   }

//   void loadRewarded() {
//     RewardedAd.load(
//       adUnitId: kReleaseMode
//           ? 'YOUR_REWARDED_AD_UNIT_ID'
//           : 'ca-app-pub-3940256099942544/5224354917', // TEST
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (ad) {
//           _rewardedAd = ad;
//           _isRewardedReady.value = true;
//         },
//         onAdFailedToLoad: (error) {
//           _isRewardedReady.value = false;
//         },
//       ),
//     );
//   }

//   // ---------------- SHOW ADS ----------------

//   void showInterstitial(VoidCallback onComplete) {
//     if (_isInterstitialReady.value && _interstitialAd != null) {
//       _interstitialAd!.fullScreenContentCallback =
//           FullScreenContentCallback(
//         onAdDismissedFullScreenContent: (ad) {
//           ad.dispose();
//           loadInterstitial();
//           onComplete();
//         },
//         onAdFailedToShowFullScreenContent: (ad, error) {
//           ad.dispose();
//           loadInterstitial();
//           onComplete();
//         },
//       );
//       _interstitialAd!.show();
//       _interstitialAd = null;
//       _isInterstitialReady.value = false;
//     } else {
//       onComplete(); // fallback
//     }
//   }

//   void showRewarded(VoidCallback onComplete) {
//     if (_isRewardedReady.value && _rewardedAd != null) {
//       _rewardedAd!.fullScreenContentCallback =
//           FullScreenContentCallback(
//         onAdDismissedFullScreenContent: (ad) {
//           ad.dispose();
//           loadRewarded();
//         },
//         onAdFailedToShowFullScreenContent: (ad, error) {
//           ad.dispose();
//           loadRewarded();
//         },
//       );

//       _rewardedAd!.show(
//         onUserEarnedReward: (ad, reward) {
//           onComplete(); // user earned reward → navigate
//         },
//       );

//       _rewardedAd = null;
//       _isRewardedReady.value = false;
//     } else {
//       onComplete(); // fallback
//     }
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     loadInterstitial();
//     loadRewarded();
//   }
// }
