import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';

class OnboardingStartPage extends StatelessWidget {
  final VoidCallback onContinue;

  const OnboardingStartPage({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            'assets/images/gif1-nobg.gif',
            height: getVerticalSize(250, context),
          ),
          Spacer(
            flex: 3,
          ),
          CustomButton(
            text: 'Continue',
            color: AppColors.buttonColor,
            onpressed: onContinue,
          ),
          SizedBox(height: getVerticalSize(30, context))
        ],
      ),
    );
  }
}
