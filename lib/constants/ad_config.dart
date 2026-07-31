import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralised AdMob configuration.
///
/// In debug / profile builds Google's official test ad unit IDs are used so
/// that no real impressions are generated during development.
/// In release builds the production IDs below are used — replace the
/// placeholder strings with your real ad unit IDs from the AdMob console
/// before publishing.
class AdConfig {
  AdConfig._(); // non-instantiable

  // ─── Google Official Test IDs ──────────────────────────────────────────────
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  // ─── Production IDs ── REPLACE BEFORE PUBLISHING ──────────────────────────
  // 1. Create your ad units in the AdMob console (admob.google.com).
  // 2. Paste the generated IDs below.
  // 3. Also update the App IDs in AndroidManifest.xml and Info.plist.
  static const String _prodBannerAndroid = 'ca-app-pub-5347757180230621/6170737776';
  static const String _prodBannerIos = 'ca-app-pub-5347757180230621/2828660070';
  static const String _prodInterstitialAndroid = 'ca-app-pub-5347757180230621/6797423731';
  static const String _prodInterstitialIos = 'ca-app-pub-5347757180230621/6352403892';

  // ─── Active IDs (auto-selected by build mode) ─────────────────────────────

  /// Adaptive banner ad unit ID for the current platform and build mode.
  static String get bannerAdUnitId {
    if (kDebugMode || kProfileMode) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIos;
    }
    return Platform.isAndroid ? _prodBannerAndroid : _prodBannerIos;
  }

  /// Interstitial ad unit ID for the current platform and build mode.
  static String get interstitialAdUnitId {
    if (kDebugMode || kProfileMode) {
      return Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIos;
    }
    return Platform.isAndroid ? _prodInterstitialAndroid : _prodInterstitialIos;
  }

  // ─── Frequency Control ────────────────────────────────────────────────────

  /// Minimum elapsed time between two interstitial impressions.
  static const Duration interstitialCooldown = Duration(minutes: 8);
}
