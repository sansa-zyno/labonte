import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:french_app/constants/ad_config.dart';
import 'package:french_app/models/entitlement.dart';

/// Manages the full interstitial ad lifecycle for free-tier users.
///
/// Responsibilities:
/// - Preloads the next interstitial immediately after the previous one is dismissed.
/// - Enforces an 8-minute cooldown between impressions.
/// - Prevents consecutive interstitials.
/// - Immediately clears any loaded ad when the user subscribes.
/// - Never affects app navigation or stability on failure.
///
/// Usage:
/// ```dart
/// // In providers list (main.dart):
/// ChangeNotifierProvider(create: (_) => AdService()),
///
/// // Trigger after lesson completed:
/// context.read<AdService>().showInterstitialIfReady(context);
/// ```
class AdService extends ChangeNotifier {
  AdService() {
    _loadInterstitial();
  }

  // ─── State ────────────────────────────────────────────────────────────────

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  bool _isLoading = false;

  /// Tracks whether the current user holds an active subscription.
  /// Updated by [setSubscriptionStatus] whenever [EntitlementProvider] changes.
  Entitlement _entitlement = Entitlement.free;

  /// Timestamp of the last interstitial impression.
  DateTime? _lastShownAt;

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Called by the subscription bridge in [main.dart] whenever
  /// [EntitlementProvider.entitlement] changes.
  void setEntitlement(Entitlement entitlement) {
    _entitlement = entitlement;
    if (entitlement == Entitlement.pro) {
      _clearLoadedAd();
    } else {
      // Re-preload if transitioning back to free (edge case)
      if (!_isInterstitialLoaded && !_isLoading) {
        _loadInterstitial();
      }
    }
  }

  /// Attempts to show the interstitial if all conditions are met:
  /// 1. User is on the free tier.
  /// 2. An ad is preloaded.
  /// 3. The cooldown period has elapsed.
  ///
  /// This method is non-blocking: if any condition fails, it returns
  /// immediately and normal app flow continues.
  void showInterstitialIfReady() {
    if (_entitlement == Entitlement.pro) {
      _debugLog('Interstitial skipped — user is subscribed.');
      return;
    }

    if (!_isInterstitialLoaded || _interstitialAd == null) {
      _debugLog('Interstitial skipped — no ad loaded yet.');
      return;
    }

    if (!_isCooldownElapsed()) {
      _debugLog('Interstitial skipped — cooldown not elapsed.');
      return;
    }

    _lastShownAt = DateTime.now();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _debugLog('Interstitial dismissed — disposing and preloading next.');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
        // Preload immediately after dismissal so the next trigger is ready.
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _debugLog('Interstitial failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
        _loadInterstitial();
      },
      onAdShowedFullScreenContent: (_) {
        _debugLog('Interstitial shown successfully.');
      },
    );

    _interstitialAd!.show();
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  /// Loads the next interstitial in the background.
  /// Safe to call multiple times — guards against duplicate loads.
  void _loadInterstitial() {
    if (_entitlement == Entitlement.pro) return;
    if (_isLoading || _isInterstitialLoaded) return;

    _isLoading = true;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _debugLog('Interstitial preloaded successfully.');
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _debugLog('Interstitial failed to preload: ${error.message}');
          _isInterstitialLoaded = false;
          _isLoading = false;
          // Retry after a delay to avoid hammering the network on failure.
          Future.delayed(const Duration(minutes: 2), () {
            if (_entitlement == Entitlement.free && !_isInterstitialLoaded) {
              _loadInterstitial();
            }
          });
        },
      ),
    );
  }

  /// Returns true if enough time has passed since the last interstitial.
  bool _isCooldownElapsed() {
    if (_lastShownAt == null) return true;
    return DateTime.now().difference(_lastShownAt!) >= AdConfig.interstitialCooldown;
  }

  /// Disposes any loaded ad when the user subscribes.
  void _clearLoadedAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
    _isLoading = false;
    _debugLog('Ads cleared — user is now subscribed.');
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      log('[AdService] $message');
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
