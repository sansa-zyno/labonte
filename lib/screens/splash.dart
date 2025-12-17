import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'dart:async';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/modals/alert.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/getting_started.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AppProvider appProvider;
  late EntitlementProvider entitlementProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    appProvider = Provider.of<AppProvider>(context, listen: false);
    entitlementProvider = Provider.of<EntitlementProvider>(context, listen: false);
    // Delay for 2 seconds before navigating to the main screen
    Timer(const Duration(seconds: 2), () async {
      if (_auth.currentUser == null) {
        changeScreenReplacement(context, const GettingStarted());
      } else {
        await appProvider.getCurrentUserModel();
        await appProvider.getContinueLessonData();
        if (appProvider.userModel != null) {
          await Purchases.logIn(appProvider.userModel!.id);
          await entitlementProvider.init();
          changeScreenReplacement(context, BottomNavbar(pageIndex: 0));
        } else {
          showDialog(
            context: context,
            builder: (ctx) => ShowDialogWidget(titleText: 'An error occurred, please check your network', subText: ""),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
        systemNavigationBarColor: AppColors.primaryColor,
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.primaryColor, // Same background as splash
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            // Main Image
            Center(
              child: Container(
                padding: getPadding(context: context, all: 8),
                height: getSize(225, context),
                width: getSize(225, context),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.whiteColor2,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      AppImages.splashImage,
                      width: getHorizontalSize(100, context),
                      height: getVerticalSize(100, context),
                    ), // Adjust size as needed
                    SizedBox(height: getVerticalSize(15, context)),
                    Text(
                      'La Bonte',
                      style: TextStyle(
                        fontSize: getFontSize(18, context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: getVerticalSize(10, context)),
                    Text(
                      'Your standard French learning app.',
                      style: TextStyle(fontSize: getFontSize(11, context), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Text(
              'La Bonte', // Bottom branding text
              style: TextStyle(fontSize: getFontSize(18, context), fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: getVerticalSize(20, context)), // Add spacing for bottom alignment
          ],
        ),
      ),
    );
  }
}
