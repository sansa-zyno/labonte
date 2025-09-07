import 'package:flutter/cupertino.dart';
import 'package:french_app/models/entitlement.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class EntitlementProvider extends ChangeNotifier {
  EntitlementProvider() {
    init();
  }

  Entitlement _entitlement = Entitlement.free;
  Entitlement get entitlement => _entitlement;

  Future init() async {
    Purchases.addCustomerInfoUpdateListener((_) => updateCustomerStatus());
    await updateCustomerStatus();
  }

  Future updateCustomerStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();
    final entitlements = customerInfo.entitlements.active.values.toList();
    _entitlement = entitlements.isEmpty ? Entitlement.free : Entitlement.allcourses;
    notifyListeners();
  }
}
