import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenProvider with ChangeNotifier {
  final adUnitId = "ca-app-pub-3940256099942544/5224354917";
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
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          log("$ad loaded");
          _showAd(ad);
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          log('Rewarded failed to load');
          isFailedToLoad = true;
          isBtnClicked = false;
          notifyListeners();
        },
      ),
    );
  }

  void _showAd(RewardedAd ad) {
    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        log('User earned reward');
        var tokens = tokensAvailable + 3;
        sharedPrefs?.setInt('tokens', tokens);
        isBtnClicked = false;
        notifyListeners();
      },
    );
  }
}
