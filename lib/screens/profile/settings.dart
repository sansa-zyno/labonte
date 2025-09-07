import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_icons.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/screens/getting_started.dart';
import 'package:french_app/services/auth.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppProvider appProvider;
  @override
  Widget build(BuildContext context) {
    appProvider = Provider.of<AppProvider>(context);
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
                  child: Icon(Icons.arrow_back),
                ),
                Spacer(),
                CustomText(
                  text: 'Settings',
                  size: getFontSize(18, context),
                  weight: FontWeight.w500,
                ),
                Spacer(),
                SizedBox(width: 30)
              ],
            ),
            SizedBox(height: getVerticalSize(15, context)),
            CustomText(text: '${appProvider.userModel?.name ?? 'N/A'}', size: getFontSize(20, context), weight: FontWeight.w500),
            SizedBox(height: getVerticalSize(5, context)),
            CustomText(text: '${appProvider.userModel?.email ?? 'N/A'}', size: 12, weight: FontWeight.w300, lineHeight: 1),
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
              onTap: () async {
                await requestReview();
              },
              visualDensity: VisualDensity(vertical: -4),
              contentPadding: EdgeInsets.all(0),
              leading: Image.asset(AppIcons.star, height: getSize(20, context)),
              title: CustomText(text: 'Rate this App'),
              trailing: Icon(Icons.arrow_forward_ios, size: 20),
            ),
            Divider(color: AppColors.lightGrey3),
            ListTile(
              onTap: () async {
                await SharePlus.instance.share(ShareParams(text: 'hello'));
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
                await AuthService.signOut();
                changeScreenRemoveUntill(context, GettingStarted());
              },
              visualDensity: VisualDensity(vertical: -4),
              contentPadding: EdgeInsets.all(0),
              leading: Image.asset(AppIcons.logout, color: Colors.black, height: getSize(20, context)),
              title: CustomText(text: 'Logout', color: AppColors.red.withOpacity(0.7)),
              trailing: Icon(Icons.arrow_forward_ios, size: 20),
            )
          ],
        ),
      ),
    );
  }

  Future<void> launchEmail() async {
    final url = 'mailto:"labontelanguages.com@gmail.com"';
    await launchUrl(Uri.parse(url));
  }

  Future<void> requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview(); // Shows the native dialog
    } else {
      // Optionally open the store listing if in-app review isn't available
      inAppReview.openStoreListing(appStoreId: 'your_ios_app_id', microsoftStoreId: 'com.labonte.www');
    }
  }
}
