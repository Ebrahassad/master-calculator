import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

/// معرفات الإعلانات الخاصة بالتطبيق (Unity Ads)
class AdIds {
  static const String gameId = '800379858';
  static const String banner = 'BP_Banner_Android';
  static const String interstitial = 'BP_Interstitial_Android';
  static const String rewarded = 'BP_Rewarded_Android';
}

/// خدمة مركزية لإدارة إعلانات Unity Ads (تهيئة + تحميل مسبق + عرض)
/// وضع الاختبار (testMode) يُفعَّل تلقائيًا في نسخة التصحيح (debug) فقط،
/// ويُعطَّل تلقائيًا في نسخة الإصدار (release) لعرض إعلانات حقيقية.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _initialized = false;
  bool _interstitialReady = false;
  bool _rewardedReady = false;

  /// يُستدعى مرة واحدة عند إقلاع التطبيق
  Future<void> init() async {
    if (_initialized) return;
    UnityAds.init(
      gameId: AdIds.gameId,
      testMode: kDebugMode,
      onComplete: () {
        _initialized = true;
        _preloadInterstitial();
        _preloadRewarded();
      },
      onFailed: (error, message) {
        debugPrint('Unity Ads init failed: $error - $message');
      },
    );
  }

  // ---------------- إعلان بيني (Interstitial) ----------------
  void _preloadInterstitial() {
    UnityAds.load(
      placementId: AdIds.interstitial,
      onComplete: (placementId) => _interstitialReady = true,
      onFailed: (placementId, error, message) {
        _interstitialReady = false;
        debugPrint('Interstitial load failed: $error - $message');
      },
    );
  }

  /// يعرض إعلانًا بينيًا إن كان جاهزًا، ثم يعيد تحميل التالي تلقائيًا
  void showInterstitial() {
    if (!_initialized || !_interstitialReady) return;
    _interstitialReady = false;
    UnityAds.showVideoAd(
      placementId: AdIds.interstitial,
      onComplete: (placementId) => _preloadInterstitial(),
      onSkipped: (placementId) => _preloadInterstitial(),
      onFailed: (placementId, error, message) {
        debugPrint('Interstitial show failed: $error - $message');
        _preloadInterstitial();
      },
    );
  }

  // ---------------- إعلان مكافأة (Rewarded) ----------------
  void _preloadRewarded() {
    UnityAds.load(
      placementId: AdIds.rewarded,
      onComplete: (placementId) => _rewardedReady = true,
      onFailed: (placementId, error, message) {
        _rewardedReady = false;
        debugPrint('Rewarded load failed: $error - $message');
      },
    );
  }

  bool get isRewardedReady => _rewardedReady;

  /// يعرض إعلان مكافأة، ويستدعي onReward فقط إذا أكمل المستخدم المشاهدة كاملة
  void showRewarded({required VoidCallback onReward, VoidCallback? onNotReady}) {
    if (!_initialized || !_rewardedReady) {
      onNotReady?.call();
      return;
    }
    _rewardedReady = false;
    UnityAds.showVideoAd(
      placementId: AdIds.rewarded,
      onComplete: (placementId) {
        onReward();
        _preloadRewarded();
      },
      onSkipped: (placementId) => _preloadRewarded(),
      onFailed: (placementId, error, message) {
        debugPrint('Rewarded show failed: $error - $message');
        _preloadRewarded();
      },
    );
  }
}
