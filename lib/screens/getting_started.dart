import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/screens/auth/log_in.dart';
import 'package:french_app/screens/auth/sign_up.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';

class GettingStarted extends StatelessWidget {
  const GettingStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.whiteColor2,
        systemNavigationBarColor: AppColors.whiteColor1,
      ),
      child: Scaffold(
          backgroundColor: AppColors.whiteColor2,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Spacer(flex: 1),
                Image.asset(
                  //AppImages.image1,
                  'assets/images/gif1-nobg.gif',
                  height: getVerticalSize(250, context),
                ),
                SizedBox(height: getVerticalSize(8, context)),
                CustomText(
                  text: 'La Bonte',
                  size: getFontSize(fontSizeExtraBig, context),
                  weight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: getVerticalSize(8, context)),
                CustomText(
                  text: 'Your standard French learning app',
                  size: getFontSize(fontSizeBig, context),
                  weight: FontWeight.w500,
                ),
                Spacer(flex: 2),
                CustomButton(
                  text: 'Get started',
                  color: AppColors.buttonColor,
                  onpressed: () {
                    changeScreen(context, const SignUp());
                  },
                ),
                SizedBox(height: getVerticalSize(15, context)),
                CustomButton(
                  text: 'I already have an account',
                  textColor: AppColors.primaryColor,
                  border: Border.all(color: AppColors.primaryColor, width: 1.5),
                  onpressed: () {
                    changeScreen(context, const Login());
                  },
                ),
                SizedBox(height: getVerticalSize(30, context))
              ],
            ),
          )),
    );
  }
}
