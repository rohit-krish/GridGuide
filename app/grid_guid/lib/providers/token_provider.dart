import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenProvider with ChangeNotifier {
  final adUnitId = "ca-app-pub-7407071925527945/5421177988";

  bool isFailedToLoad = false;
  SharedPreferences? sharedPrefs;
  bool isBtnClicked = false;
  void btnClicked() {
    isFailedToLoad = false;
    isBtnClicked = true;
    notifyListeners();
    _loadAd();
  }

  void init(SharedPreferences? homeSharedPrefs) {
    sharedPrefs = homeSharedPrefs;
  }

  int get tokensAvailable => sharedPrefs?.getInt('tokens') ?? 1;
  void _loadAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
        _showAd(ad);
      }, onAdFailedToLoad: (LoadAdError error) {
        isFailedToLoad = true;
        isBtnClicked = false;
        notifyListeners();
      }),
    );
  }

  void _showAd(RewardedAd ad) {
    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      var tokens = tokensAvailable + 3;
      sharedPrefs?.setInt('tokens', tokens);
      isBtnClicked = false;
      notifyListeners();
    });
  }
}
