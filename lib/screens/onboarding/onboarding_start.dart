import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/modals/alert.dart';
import 'package:french_app/models/user.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/services/firebase_notifications_service.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:french_app/screens/onboarding/widgets/onboarding_start_page.dart';
import 'package:french_app/screens/onboarding/widgets/onboarding_page1.dart';
import 'package:french_app/screens/onboarding/widgets/onboarding_page2.dart';
import 'package:french_app/screens/onboarding/widgets/onboarding_page3.dart';
import 'package:french_app/screens/onboarding/widgets/onboarding_page4.dart';
import 'package:french_app/screens/onboarding/widgets/onboarding_page5.dart';
import 'package:french_app/screens/onboarding/widgets/onboarding_finished_page.dart';

class OnboardingStart extends StatefulWidget {
  final UserModel userModel;
  const OnboardingStart({super.key, required this.userModel});

  @override
  State<OnboardingStart> createState() => _OnboardingStartState();
}

class _OnboardingStartState extends State<OnboardingStart> {
  late PageController _pageController;
  late UserModel userModel;

  // Page 1 (Onboarding1) state
  int page1SelectedIdx = -1;
  String page1SelectedVal = '';

  // Page 2 (Onboarding2) state
  int page2SelectedIdx = -1;
  String page2SelectedVal = '';

  // Page 3 (Onboarding4) state
  Set page3SelectedVals = {};

  // Page 4 (Onboarding5) state
  Set page4SelectedVals = {};

  // Page 5 (Onboarding6) state
  int page5SelectedIdx = -1;
  String page5SelectedVal = '';

  // Progress tracking
  // Total 5 question pages. Each base adds 0.08, selection adds another 0.08
  // Page0 = start (no progress bar), Page1..5 = questions, Page6 = finished
  int _currentPage = 0;

  Timer? _finishedTimer;

  double get progressVal {
    // Each question page contributes up to 0.2 (1.0 / 5 pages)
    // Base progress when landing on a page + bonus when selected
    double val = 0.0;
    // Page 1
    if (_currentPage >= 1) {
      val += 0.08;
      if (page1SelectedVal.isNotEmpty) val += 0.08;
    }
    // Page 2
    if (_currentPage >= 2) {
      val += 0.08;
      if (page2SelectedVal.isNotEmpty) val += 0.08;
    }
    // Page 3
    if (_currentPage >= 3) {
      val += 0.08;
      if (page3SelectedVals.isNotEmpty) val += 0.08;
    }
    // Page 4
    if (_currentPage >= 4) {
      val += 0.08;
      if (page4SelectedVals.isNotEmpty) val += 0.08;
    }
    // Page 5
    if (_currentPage >= 5) {
      val += 0.08;
      if (page5SelectedVal.isNotEmpty) val += 0.08;
    }
    // Finished page
    if (_currentPage >= 6) {
      val = 1.0;
    }
    return val;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    userModel = widget.userModel;
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_finishedTimer != null) {
      _finishedTimer!.cancel();
      _finishedTimer = null;
    }
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousPage() {
    if (_currentPage == 0) {
      Navigator.pop(context);
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // If we land on the finished page, trigger save
    if (page == 6) {
      _onFinished();
    }
  }

  void _onFinished() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final entitlementProvider =
        Provider.of<EntitlementProvider>(context, listen: false);
    _finishedTimer = Timer(const Duration(seconds: 1), () async {
      await DatabaseService.updateUser(userModel.id, userModel);
      await appProvider.getCurrentUserModel();
      await appProvider.getContinueLessonData();
      if (appProvider.userModel != null) {
        await Purchases.logIn(userModel.id);
        await entitlementProvider.init();
        FirebaseNotificationService.initialize();
        changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0));
      } else {
        showDialog(
          context: context,
          builder: (ctx) => ShowDialogWidget(
              titleText: 'An error occurred, please check your network',
              subText: ""),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.whiteColor2),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor2,
        body: Column(
          children: [
            if (_currentPage > 0 && _currentPage < 6)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    SizedBox(height: appBarSpace),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                          onTap: () {
                            _goToPreviousPage();
                          },
                          child: Icon(
                            Platform.isAndroid
                                ? Icons.arrow_back
                                : Icons.arrow_back_ios,
                            size: getSize(20, context),
                          )),
                    ),
                    SizedBox(height: getVerticalSize(15, context)),
                    LinearProgressIndicator(
                      value: progressVal,
                      minHeight: 10,
                      backgroundColor: Colors.grey.withValues(alpha: 0.5),
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
            if (_currentPage == 6)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 90),
                    LinearProgressIndicator(
                      value: 1.0,
                      minHeight: 10,
                      backgroundColor: Colors.grey.withValues(alpha: 0.5),
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _onPageChanged,
                children: [
                  OnboardingStartPage(
                    onContinue: () {
                      _goToNextPage();
                    },
                  ),
                  OnboardingPage1(
                    selectedIdx: page1SelectedIdx,
                    selectedVal: page1SelectedVal,
                    onSelectionChanged: (idx, val) {
                      setState(() {
                        page1SelectedIdx = idx;
                        page1SelectedVal = val;
                      });
                    },
                    onContinue: () {
                      userModel =
                          userModel.copyWith(userFrenchLevel: page1SelectedVal);
                      _goToNextPage();
                    },
                  ),
                  OnboardingPage2(
                    selectedIdx: page2SelectedIdx,
                    selectedVal: page2SelectedVal,
                    onSelectionChanged: (idx, val) {
                      setState(() {
                        page2SelectedIdx = idx;
                        page2SelectedVal = val;
                      });
                    },
                    onContinue: () {
                      userModel = userModel.copyWith(
                          frequencyOfLearning: page2SelectedVal);
                      _goToNextPage();
                    },
                  ),
                  OnboardingPage3(
                    selectedVals: page3SelectedVals,
                    onSelectionChanged: (vals) {
                      setState(() {
                        page3SelectedVals = vals;
                      });
                    },
                    onContinue: () {
                      userModel = userModel.copyWith(
                          purposeForLearning:
                              List<String>.from(page3SelectedVals));
                      _goToNextPage();
                    },
                  ),
                  OnboardingPage4(
                    selectedVals: page4SelectedVals,
                    onSelectionChanged: (vals) {
                      setState(() {
                        page4SelectedVals = vals;
                      });
                    },
                    onContinue: () {
                      userModel = userModel.copyWith(
                          learningGoals: List<String>.from(page4SelectedVals));
                      _goToNextPage();
                    },
                  ),
                  OnboardingPage5(
                    selectedIdx: page5SelectedIdx,
                    selectedVal: page5SelectedVal,
                    onSelectionChanged: (idx, val) {
                      setState(() {
                        page5SelectedIdx = idx;
                        page5SelectedVal = val;
                      });
                    },
                    onContinue: () {
                      userModel =
                          userModel.copyWith(heardAboutUs: page5SelectedVal);
                      _goToNextPage();
                    },
                  ),
                  const OnboardingFinishedPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
