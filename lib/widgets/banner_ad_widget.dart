import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:french_app/constants/ad_config.dart';
import 'package:french_app/models/entitlement.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:provider/provider.dart';

/// A self-contained, adaptive banner ad widget.
///
/// - Renders nothing ([SizedBox.shrink]) for subscribed users.
/// - Renders nothing when the ad fails to load.
/// - Disposes the [BannerAd] correctly in [dispose].
/// - Never loads an ad if the user is on the pro tier.
///
/// Place at the bottom of low-engagement screens only (Home, Profile, Settings).
/// Do NOT place on any learning/exercise/quiz screen.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  bool _isInitialLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _isInitialLoad = false;
      // Only load if the user is on the free tier.
      final entitlement = context.read<EntitlementProvider>().entitlement;
      if (entitlement == Entitlement.free) {
        _loadBannerAd();
      }
    }
  }

  Future<void> _loadBannerAd() async {
    // Calculate the adaptive banner size from the screen width.
    final screenWidth = MediaQuery.of(context).size.width.truncate();
    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      screenWidth,
    );

    if (adSize == null) {
      if (kDebugMode) log('[BannerAdWidget] Failed to get adaptive ad size.');
      return;
    }

    final ad = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          if (kDebugMode) log('[BannerAdWidget] Banner loaded.');
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode)
            log('[BannerAdWidget] Banner failed: ${error.message}');
          ad.dispose();
        },
      ),
    );

    await ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Re-check subscription status reactively.
    final entitlement = context.watch<EntitlementProvider>().entitlement;

    // Never show ads to subscribed users, even if an ad loaded before they subscribed.
    if (entitlement == Entitlement.pro || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
