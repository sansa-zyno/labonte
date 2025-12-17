/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/user.dart';
import 'package:french_app/screens/onboarding/onboarding4.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';

class Onboarding3 extends StatefulWidget {
  final double progressVal;
  final UserModel userModel;
  const Onboarding3({super.key, required this.progressVal, required this.userModel});

  @override
  State<Onboarding3> createState() => _Onboarding3State();
}

class _Onboarding3State extends State<Onboarding3> {
  double progressVal = 0;
  bool notify = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    progressVal = widget.progressVal + 0.08;
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
              SizedBox(height: appBarSpace),
               Align(
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
              SizedBox(height: getVerticalSize(15, context)),
              LinearProgressIndicator(
                value: progressVal,
                minHeight: 10,
                backgroundColor: Colors.grey.withOpacity(0.5),
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              CustomText(
                text: 'Let\'s Smash This Goal Together!',
                size: getFontSize(fontSizeBig, context),
                weight: FontWeight.bold,
              ),
              SizedBox(height: getVerticalSize(15, context)),
              CustomText(
                text: 'Stay on track with personalized reminders',
                lineHeight: 1,
                size: getFontSize(fontSizeSmall, context),
              ),
              SizedBox(height: getVerticalSize(20, context)),
              Image.asset(AppImages.calendar),
              SizedBox(height: getVerticalSize(15, context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Enable Notifications',
                    size: getFontSize(fontSizeSmall, context),
                  ),
                  Switch(
                    value: notify,
                    activeColor: AppColors.greenColor,
                    onChanged: (x) {
                      if (x) {
                        progressVal = widget.progressVal + 0.16;
                        notify = x;
                        setState(() {});
                      } else {
                        progressVal = widget.progressVal + 0.08;
                        notify = x;
                        setState(() {});
                      }
                    },
                  )
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 65),
                child: CustomButton(
                  text: 'Continue',
                  color: AppColors.buttonColor,
                  onpressed: () {
                    changeScreen(context, Onboarding4(progressVal: progressVal, userModel: widget.userModel));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
