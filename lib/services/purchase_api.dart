import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseApi {
  static Future<void> init() async {
    //await Purchases.setLogLevel(LogLevel.info);
    late PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(dotenv.env['REVENUECAT_PROJECT_GOOGLE_API_KEY'] ?? '');
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(dotenv.env['REVENUECAT_PROJECT_APPLE_API_KEY'] ?? '');
    }
    await Purchases.configure(configuration);
  }

  static Future<List<Offering>> fetchOffers({bool all = true}) async {
    try {
      final offerings = await Purchases.getOfferings();
      if (!all) {
        final current = offerings.current;
        return current == null ? [] : [current];
      } else {
        return offerings.all.values.toList();
      }
    } on PlatformException catch (e) {
      log(e.toString());
      return [];
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchase(PurchaseParams.package(package));
      return true;
    } catch (e) {
      return false;
    }
  }
}
