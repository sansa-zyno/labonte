import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/dummy_data.dart';
import 'package:french_app/models/user.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/paywall_widget.dart';
import 'package:provider/provider.dart';

class Subscription extends StatefulWidget {
  final UserModel userModel;
  const Subscription({required this.userModel, super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.whiteColor1),
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: getVerticalSize(70, context)),
            Stack(
              children: [
                Image.asset(
                  AppImages.vector1,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Positioned(left: 30, top: 10, child: Image.asset(AppImages.girl)),
                Positioned(left: 150, child: Image.asset(AppImages.bonjour)),
                Positioned(right: 0, top: -5, child: Image.asset(AppImages.book)),
                Positioned(right: 0, bottom: 50, child: Image.asset(AppImages.stars)),
                Positioned(
                  left: 15,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: getVerticalSize(15, context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  CustomText(
                    text: 'Start Your Free Trial - Learn French With No Risk',
                    size: getFontSize(20, context),
                    weight: FontWeight.bold,
                  ),
                  SizedBox(height: getVerticalSize(15, context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity(horizontal: -4),
                              fillColor: WidgetStatePropertyAll(Colors.black),
                              value: true,
                              onChanged: (x) {},
                            ),
                            SizedBox(height: getHorizontalSize(5, context)),
                            Expanded(
                                child: CustomText(
                              text: 'Access to 5 French lessons',
                            ))
                          ],
                        ),
                        SizedBox(height: getVerticalSize(5, context)),
                        Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity(horizontal: -4),
                              fillColor: WidgetStatePropertyAll(Colors.black),
                              value: true,
                              onChanged: (x) {},
                            ),
                            SizedBox(height: getHorizontalSize(5, context)),
                            Expanded(
                                child: CustomText(
                              text: '3-day free trial with full features',
                            ))
                          ],
                        ),
                        SizedBox(height: getVerticalSize(5, context)),
                        Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity(horizontal: -4),
                              fillColor: WidgetStatePropertyAll(Colors.black),
                              value: true,
                              onChanged: (x) {},
                            ),
                            SizedBox(height: getHorizontalSize(5, context)),
                            Expanded(
                                child: CustomText(
                              text: 'Cancel anytime within the trial period at no cost',
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getVerticalSize(30, context)),
                  CustomButton(
                    width: getHorizontalSize(200, context),
                    text: 'Start your 3-days free trial',
                    color: AppColors.buttonColor,
                    onpressed: () async {
                      // fetchOffers(context);
                      List<Package> packagess = DummyData.packagess;
                      showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          barrierColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
                          builder: (bottomSheetContext) => PaywallWidget(
                              title: "Get full access",
                              description: "",
                              packages: packagess,
                              onClickedPackage: (package) async {
                                // await PurchaseApi.purchasePackage(package);

                                // Close bottom sheet first
                                Navigator.pop(bottomSheetContext);

                                // Delay a frame to let bottom sheet fully dismiss
                                await Future.delayed(Duration(milliseconds: 100));

                                // Access parent context (not bottomSheetContext) safely
                                final appProvider = Provider.of<AppProvider>(context, listen: false);

                                await appProvider.getCurrentUserModel();
                                await appProvider.getContinueLessonData();

                                if (context.mounted) {
                                  changeScreenReplacement(context, BottomNavbar(pageIndex: 0));
                                }
                              }));
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

  /*Future fetchOffers(context) async {
    final offerings = await PurchaseApi.fetchOffers(all: false);
    if (offerings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No Plans Found')));
    } else {
      final packages = offerings.map((offer) => offer.availablePackages).expand((pair) => pair).toList();
      showModalBottomSheet(
          context: context,
          builder: (context) => PaywallWidget(
              title: "Upgrade your Plan",
              description: "Upgrade to a new plan to enjoy more benefits",
              packages: packages,
              onClickedPackage: (package) async {
                await PurchaseApi.purchasePackage(package);
                Navigator.pop(context);
              }));
    }
  }*/
}
