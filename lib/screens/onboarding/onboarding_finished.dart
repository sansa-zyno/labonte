import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/modals/alert.dart';
import 'package:french_app/models/user.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/services/database.dart';
import 'package:provider/provider.dart';

class OnboardingFinished extends StatefulWidget {
  final UserModel userModel;
  const OnboardingFinished({super.key, required this.userModel});

  @override
  State<OnboardingFinished> createState() => _OnboardingFinishedState();
}

class _OnboardingFinishedState extends State<OnboardingFinished> {
  late AppProvider appProvider;
  Timer? timer;
  goToNextScreen() async {
    timer = Timer(const Duration(seconds: 1), () async {
      await DatabaseService.updateUser(widget.userModel.id, widget.userModel);
      await appProvider.getCurrentUserModel();
      await appProvider.getContinueLessonData();
      if (appProvider.userModel != null) {
        changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0));
      } else {
        showDialog(
          context: context,
          builder: (ctx) => ShowDialogWidget(titleText: 'An error occurred, please check your network', subText: ""),
        );
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appProvider = Provider.of<AppProvider>(context, listen: false);
    goToNextScreen();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.whiteColor2),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor2,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            children: [
              const SizedBox(height: 90),
              LinearProgressIndicator(
                value: 1.0,
                minHeight: 10,
                backgroundColor: Colors.grey.withOpacity(0.5),
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              Spacer(flex: 2),
              Image.asset(AppImages.success),
              Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
