//import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:french_app/models/entitlement.dart';
import 'package:french_app/services/database.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class EntitlementProvider extends ChangeNotifier {
  EntitlementProvider();

  Entitlement _entitlement = Entitlement.free;
  Entitlement get entitlement => _entitlement;
  EntitlementInfo? entitlementInfo;
  // Keep a reference to the listener function
  CustomerInfoUpdateListener? customerInfoListener;

  Future<void> init() async {
    // ignore: prefer_conditional_assignment
    if (customerInfoListener == null) {
      customerInfoListener = (customerInfo) async {
        final entitlements = customerInfo.entitlements.active.values.toList();
        //log("AddCustomerInfoUpdateListener ENTITLEMENTS list for this user : ${entitlements.toString()}");
        if (entitlements.isNotEmpty) {
          _entitlement = Entitlement.pro;
          entitlementInfo = entitlements[0];
          // log("AddCustomerInfoUpdateListener ENTITLEMENTS period type : ${entitlements[0].periodType.name}");
          String userId = await Purchases.appUserID;
          DatabaseService.updateUserSubscriptionStatus(userId, true);
        } else {
          _entitlement = Entitlement.free;
          String userId = await Purchases.appUserID;
          DatabaseService.updateUserSubscriptionStatus(userId, false);
        }
        notifyListeners();
      };
    }
    Purchases.addCustomerInfoUpdateListener(customerInfoListener!);
    await updateCustomerStatus();
  }

  Future<void> updateCustomerStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();
    final entitlements = customerInfo.entitlements.active.values.toList();
    _entitlement = entitlements.isEmpty ? Entitlement.free : Entitlement.pro;
    notifyListeners();
  }

  String? expiryTimeCalc() {
    if (entitlementInfo == null) {
      return null;
    }
    DateTime dt = DateTime.parse(entitlementInfo!.expirationDate!);
    if (DateTime.parse(entitlementInfo!.expirationDate!).isBefore(DateTime.now())) {
      return null;
    }
    Duration dur = dt.difference(DateTime.now());
    if (dur.inSeconds < 60) {
      return "${dur.inSeconds} seconds";
    } else if (dur.inMinutes >= 1 && dur.inMinutes < 60) {
      return dur.inMinutes == 1 ? "${dur.inMinutes} min" : "${dur.inMinutes} mins";
    } else if (dur.inHours >= 1 && dur.inHours < 24) {
      return dur.inHours == 1 ? "${dur.inHours} hour" : "${dur.inHours} hours";
    } else if (dur.inDays >= 1) {
      return dur.inDays == 1 ? "${dur.inDays} day" : "${dur.inDays} days";
    } else {
      return null;
    }
  }

  void disp() {
    customerInfoListener = null;
    entitlementInfo = null;
    notifyListeners();
  }
}
