import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/services/purchase_api.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/paywall_widget.dart';
import 'package:provider/provider.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  bool canGoBack = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      canGoBack = Navigator.canPop(context);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.whiteColor1, systemNavigationBarColor: AppColors.whiteColor1),
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 0,
        ),
        body: Column(
          children: [
            SizedBox(height: getVerticalSize(30, context)),
            Stack(
              children: [
                Image.asset(
                  AppImages.vector1,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Positioned(
                    left: getHorizontalSize(30, context),
                    bottom: getVerticalSize(15, context),
                    child: Image.asset(AppImages.girl, height: getSize(151, context), fit: BoxFit.cover)),
                Positioned(
                    left: getHorizontalSize(150, context),
                    bottom: width < 600 ? getVerticalSize(15, context) : getVerticalSize(40, context),
                    child: Image.asset(AppImages.bonjour, height: getSize(157, context), fit: BoxFit.cover)),
                Positioned(
                  right: 0,
                  top: getVerticalSize(-5, context),
                  child: Image.asset(AppImages.book, height: getSize(38, context), fit: BoxFit.cover),
                ),
                Positioned(
                  right: 0,
                  bottom: getVerticalSize(50, context),
                  child: Image.asset(AppImages.stars, height: getSize(54, context), fit: BoxFit.cover),
                ),
                canGoBack
                    ? Positioned(
                        left: getHorizontalSize(15, context),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
                                size: getSize(20, context),
                              )),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            SizedBox(height: getVerticalSize(15, context)),
            Padding(
              padding: getPadding(context: context, left: 15, right: 15),
              child: Column(
                children: [
                  CustomText(
                    text: 'Unlock your full French learning experience!',
                    size: getFontSize(20, context),
                    weight: FontWeight.bold,
                  ),
                  SizedBox(height: getVerticalSize(15, context)),
                  Padding(
                    padding: getPadding(context: context, left: 15, right: 15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              fillColor: WidgetStatePropertyAll(Colors.black),
                              value: true,
                              onChanged: (x) {},
                            ),
                            SizedBox(height: getHorizontalSize(5, context)),
                            Expanded(child: CustomText(text: '3-day free trial with full features', size: getFontSize(13, context)))
                          ],
                        ),
                        SizedBox(height: getVerticalSize(5, context)),
                        Row(
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              fillColor: WidgetStatePropertyAll(Colors.black),
                              value: true,
                              onChanged: (x) {},
                            ),
                            SizedBox(height: getHorizontalSize(5, context)),
                            Expanded(child: CustomText(text: '30 interactive lessons (Beginner to Advanced)', size: getFontSize(13, context)))
                          ],
                        ),
                        SizedBox(height: getVerticalSize(5, context)),
                        Row(
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              fillColor: WidgetStatePropertyAll(Colors.black),
                              value: true,
                              onChanged: (x) {},
                            ),
                            SizedBox(height: getHorizontalSize(5, context)),
                            Expanded(child: CustomText(text: 'AI-powered tutor to answer your questions instantly', size: getFontSize(13, context)))
                          ],
                        ),
                        SizedBox(height: getVerticalSize(5, context)),
                        Row(
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              fillColor: WidgetStatePropertyAll(Colors.black),
                              value: true,
                              onChanged: (x) {},
                            ),
                            SizedBox(height: getHorizontalSize(5, context)),
                            Expanded(child: CustomText(text: 'Live tutor sessions for real-time speaking practice', size: getFontSize(13, context)))
                          ],
                        ),
                        SizedBox(height: getVerticalSize(5, context)),
                        Row(
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              fillColor: WidgetStatePropertyAll(Colors.black),
                              value: true,
                              onChanged: (x) {},
                            ),
                            SizedBox(height: getHorizontalSize(5, context)),
                            Expanded(child: CustomText(text: 'Certificate of Completion at the end of the course', size: getFontSize(13, context)))
                          ],
                        ),
                        SizedBox(height: getVerticalSize(5, context)),
                        Row(
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              fillColor: WidgetStatePropertyAll(Colors.black),
                              value: true,
                              onChanged: (x) {},
                            ),
                            SizedBox(height: getHorizontalSize(5, context)),
                            Expanded(child: CustomText(text: 'Cancel anytime within the trial period at no cost', size: getFontSize(13, context)))
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getVerticalSize(30, context)),
                  CustomButton(
                    text: 'Choose a Plan',
                    color: AppColors.buttonColor,
                    onpressed: () async {
                      fetchOffers(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future fetchOffers(context) async {
    final offerings = await PurchaseApi.fetchOffers(all: false);
    if (offerings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Plans Found')));
    } else {
      final packages = offerings.map((offer) => offer.availablePackages).expand((pair) => pair).toList();
      showModalBottomSheet(
          context: context,
          constraints: BoxConstraints(minWidth: double.infinity),
          builder: (bottomSheetContext) => PaywallWidget(
              title: "Get full access",
              description: "",
              packages: packages.reversed.toList(),
              onClickedPackage: (package) async {
                bool result = await PurchaseApi.purchasePackage(package);
                // Close bottom sheet first
                Navigator.pop(bottomSheetContext);

                // Delay a frame to let bottom sheet fully dismiss
                await Future.delayed(Duration(milliseconds: 100));

                if (result) {
                  // Access parent context (not bottomSheetContext) safely
                  final appProvider = Provider.of<AppProvider>(context, listen: false);

                  await appProvider.getCurrentUserModel();
                  await appProvider.getContinueLessonData();

                  if (context.mounted) {
                    if (canGoBack) {
                      Navigator.pop(context);
                    } else {
                      changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0));
                    }
                  }
                }
              }));
    }
  }
}
