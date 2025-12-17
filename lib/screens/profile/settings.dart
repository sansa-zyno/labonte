import 'dart:io';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_icons.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/modals/alert.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:french_app/screens/getting_started.dart';
import 'package:french_app/services/auth.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/services/local_storage.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppProvider appProvider;
  late EntitlementProvider entitlementProvider;
  bool deletingAccount = false;
  bool isLoggingOut = false;
  @override
  Widget build(BuildContext context) {
    appProvider = Provider.of<AppProvider>(context);
    entitlementProvider = Provider.of<EntitlementProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: appBarSpace),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios, size: getSize(20, context)),
                ),
                Spacer(),
                CustomText(
                  text: 'Settings',
                  size: getFontSize(18, context),
                  weight: FontWeight.w500,
                ),
                Spacer(),
                SizedBox(width: getHorizontalSize(20, context))
              ],
            ),
            SizedBox(height: getVerticalSize(15, context)),
            CustomText(text: appProvider.userModel?.name ?? 'N/A', size: getFontSize(20, context), weight: FontWeight.w500),
            SizedBox(height: getVerticalSize(3, context)),
            CustomText(text: appProvider.userModel?.email ?? 'N/A', size: getFontSize(fontSizeSmall, context), weight: FontWeight.w300),
            SizedBox(height: getVerticalSize(10, context)),
            /*Divider(color: AppColors.lightGrey3),
            ListTile(
              visualDensity: VisualDensity(vertical: -4),
              contentPadding: EdgeInsets.all(0),
              leading: Image.asset(AppIcons.web,height: getSize(20, context)),
              title: CustomText(text: 'My Languages'),
              trailing: Icon(Icons.arrow_forward_ios, size: 20),
            ),*/
            Divider(color: AppColors.lightGrey3),
            ListTile(
              onTap: () {
                requestReview();
              },
              visualDensity: VisualDensity(vertical: -4),
              contentPadding: EdgeInsets.all(0),
              leading: Image.asset(AppIcons.star, height: getSize(20, context)),
              title: CustomText(text: 'Rate this App'),
              trailing: Icon(Icons.arrow_forward_ios, size: 20),
            ),
            Divider(color: AppColors.lightGrey3),
            ListTile(
              onTap: () {
                shareStoreLink();
              },
              visualDensity: VisualDensity(vertical: -4),
              contentPadding: EdgeInsets.all(0),
              leading: Image.asset(AppIcons.share, height: getSize(20, context)),
              title: CustomText(text: 'Share'),
              trailing: Icon(Icons.arrow_forward_ios, size: 20),
            ),
            Divider(color: AppColors.lightGrey3),
            ListTile(
              onTap: () {
                launchEmail();
              },
              visualDensity: VisualDensity(vertical: -4),
              contentPadding: EdgeInsets.all(0),
              leading: Image.asset(AppIcons.help, height: getSize(20, context)),
              title: CustomText(text: 'Contact Us'),
              trailing: Icon(Icons.arrow_forward_ios, size: 20),
            ),
            Divider(color: AppColors.lightGrey3),
            ListTile(
              onTap: () async {
                await launchUrl(Uri.parse('https://labontelanguages.ca/privacy-policy/'));
              },
              visualDensity: VisualDensity(vertical: -4),
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.link, size: getSize(20, context)),
              title: CustomText(text: 'Privacy Policy'),
              trailing: Icon(Icons.arrow_forward_ios, size: 20),
            ),
            Platform.isAndroid ? SizedBox.shrink() : Divider(color: AppColors.lightGrey3),
            Platform.isAndroid
                ? SizedBox.shrink()
                : ListTile(
                    onTap: () async {
                      await launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                    },
                    visualDensity: VisualDensity(vertical: -4),
                    contentPadding: EdgeInsets.all(0),
                    leading: Icon(Icons.link, size: getSize(20, context)),
                    title: CustomText(text: 'Terms of Use (EULA)'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 20),
                  ),
            Divider(color: AppColors.lightGrey3),
            ListTile(
              onTap: () {
                logout();
              },
              visualDensity: VisualDensity(vertical: -4),
              contentPadding: EdgeInsets.all(0),
              leading: Image.asset(AppIcons.logout, color: AppColors.red.withOpacity(0.7), height: getSize(20, context)),
              title: CustomText(text: 'Logout', color: AppColors.red.withOpacity(0.7)),
              trailing: isLoggingOut
                  ? SizedBox(height: 15, width: 20, child: Padding(padding: const EdgeInsets.only(right: 5), child: CircularProgressIndicator()))
                  : Icon(Icons.arrow_forward_ios, color: AppColors.red.withOpacity(0.7), size: 20),
            ),
            Divider(color: AppColors.lightGrey3),
            ListTile(
              onTap: () {
                deleteAccount();
              },
              visualDensity: VisualDensity(vertical: -4),
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.delete, color: AppColors.red.withOpacity(0.7), size: getSize(20, context)),
              title: CustomText(text: 'Delete Account', color: AppColors.red.withOpacity(0.7)),
              trailing: deletingAccount
                  ? SizedBox(height: 15, width: 20, child: Padding(padding: const EdgeInsets.only(right: 5), child: CircularProgressIndicator()))
                  : Icon(Icons.arrow_forward_ios, color: AppColors.red.withOpacity(0.7), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> shareStoreLink() async {
    if (Platform.isAndroid) {
      await SharePlus.instance.share(ShareParams(text: 'https://play.google.com/store/apps/details?id=com.labonte.www'));
    } else {
      await SharePlus.instance.share(ShareParams(text: 'https://apps.apple.com/app/id6755325259'));
    }
  }

  Future<void> launchEmail() async {
    const url = 'mailto:"labontelanguages.com@gmail.com"';
    await launchUrl(Uri.parse(url));
  }

  Future<void> requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview(); // Shows the native dialog
    } else {
      // Optionally open the store listing if in-app review isn't available
      await inAppReview.openStoreListing(appStoreId: '6755325259', microsoftStoreId: 'com.labonte.www');
    }
  }

  Future<void> logout() async {
    setState(() {
      isLoggingOut = true;
    });
    try {
      // 1️⃣ Remove listeners first so old user events don't fire
      if (entitlementProvider.customerInfoListener != null) {
        Purchases.removeCustomerInfoUpdateListener(entitlementProvider.customerInfoListener!);
        entitlementProvider.disp();
      }
      // 2️⃣ Logout from RevenueCat — this detaches the App User ID completely
      await Purchases.logOut();
      // 3️⃣ Reset caches (optional but recommended)
      await Purchases.invalidateCustomerInfoCache();
      await AuthService.signOut();
      await LocalStorage().clearPref();
      changeScreenRemoveUntill(context, GettingStarted());
    } catch (e) {
      showDialog(context: context, builder: (ctx) => ShowDialogWidget(titleText: e.toString(), subText: ""));
    }
    setState(() {
      isLoggingOut = false;
    });
  }

  Future<void> deleteAccount() async {
    bool result = await showDialog(
        context: context,
        builder: (ctx) => ShowDialogWidget(
              isActionOptions: true,
              titleText:
                  'Are you sure you want to delete your account? If yes, make sure to also cancel your subscription from the stores to avoid auto renewal.',
              subText: "",
            ));
    if (result) {
      setState(() {
        deletingAccount = true;
      });
      try {
        if (appProvider.userModel != null) {
          await DatabaseService.deleteUser(appProvider.userModel!.id);
          await AuthService.deleteAccount();
          // 1️⃣ Remove listeners first so old user events don't fire
          if (entitlementProvider.customerInfoListener != null) {
            Purchases.removeCustomerInfoUpdateListener(entitlementProvider.customerInfoListener!);
            entitlementProvider.disp();
          }
          // 2️⃣ Logout from RevenueCat — this detaches the App User ID completely
          await Purchases.logOut();
          // 3️⃣ Reset caches (optional but recommended)
          await Purchases.invalidateCustomerInfoCache();
          await LocalStorage().clearPref();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Account deleted successfully', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
              backgroundColor: Colors.green[400]));
          changeScreenRemoveUntill(context, GettingStarted());
        }
      } catch (e) {
        showDialog(context: context, builder: (ctx) => ShowDialogWidget(titleText: e.toString(), subText: ""));
      }
      setState(() {
        deletingAccount = false;
      });
    }
  }
}
