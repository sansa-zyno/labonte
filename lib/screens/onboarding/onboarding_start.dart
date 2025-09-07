import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/user.dart';
import 'package:french_app/screens/onboarding/onboarding1.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';

class OnboardingStart extends StatefulWidget {
  final UserModel userModel;
  const OnboardingStart({super.key, required this.userModel});

  @override
  State<OnboardingStart> createState() => _OnboardingStartState();
}

class _OnboardingStartState extends State<OnboardingStart> {
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.whiteColor2),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor2,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Spacer(flex: 2),
              Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 30),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGrey2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomText(
                  text: 'Just 5 quick questions before we start your first lesson!',
                ),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              Image.asset(
                //AppImages.image1,
                'assets/images/gif1-nobg.gif',
                height: getVerticalSize(250, context),
              ),
              Spacer(
                flex: 3,
              ),
              CustomButton(
                text: 'Continue',
                color: AppColors.buttonColor,
                onpressed: () {
                  changeScreen(context, Onboarding1(userModel: widget.userModel));
                },
              ),
              SizedBox(height: getVerticalSize(30, context))
            ],
          ),
        ),
      ),
    );
  }
}
