import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_icons.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';

class AppConstants {
  static Widget buildHeaderSpeaker({
    required BuildContext context,
    required Widget icon,
    required bool loading,
    required Function callBack,
  }) =>
      Center(
        child: GestureDetector(
          onTap: () {
            if (!loading) {
              callBack();
            }
          },
          child: Container(
            width: getHorizontalSize(124, context),
            height: getVerticalSize(110, context),
            padding: loading ? null : EdgeInsets.fromLTRB(15, 5, 5, 15),
            decoration: BoxDecoration(
              color: AppColors.red4,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.red3, width: 20),
            ),
            child: Center(
                child: loading
                    ? SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : icon),
          ),
        ),
      );

  static Widget buildHeaderUserSound({
    required BuildContext context,
    required Widget icon,
    required bool loading,
    required Function callBack,
  }) =>
      Center(
        child: GestureDetector(
          onTap: () {
            if (!loading) {
              callBack();
            }
          },
          child: Container(
            width: getHorizontalSize(124, context),
            height: getVerticalSize(110, context),
            padding: loading ? null : EdgeInsets.fromLTRB(15, 5, 5, 15),
            decoration: BoxDecoration(
              color: AppColors.red4,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.red3, width: 20),
            ),
            child: Center(
                child: loading
                    ? SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : icon),
          ),
        ),
      );

  static Widget emptyLessonProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: 'Start Your First Lesson', size: getFontSize(16, context), weight: FontWeight.w600, lineHeight: 0.8),
        SizedBox(height: getVerticalSize(3, context)),
        CustomText(text: 'Begin your steps to mastering French', size: getFontSize(12, context)),
        SizedBox(height: getVerticalSize(5, context)),
        Card(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: AppColors.blackColor1.withOpacity(0.1)), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppIcons.calender, height: getSize(30, context)),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        CustomText(text: 'Learn your alphabets today', weight: FontWeight.w600),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                            value: 0.1,
                            minHeight: 10,
                            backgroundColor: Colors.grey.withOpacity(0.5),
                            color: AppColors.blueColor,
                            borderRadius: BorderRadius.circular(10))
                      ]),
                    ),
                    SizedBox(width: 15),
                    Icon(Icons.arrow_forward_ios, size: 20)
                  ],
                ),
                SizedBox(height: 20),
                CustomButton(
                  height: getVerticalSize(36, context),
                  width: getHorizontalSize(86, context),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  borderRadius: 10,
                  color: AppColors.primaryColor,
                  textColor: AppColors.whiteColor1,
                  textSize: 12,
                  text: 'Start Now',
                  onpressed: () {
                    changeScreen(
                        context,
                        BottomNavbar(
                            pageIndex: 1,
                            newpage: const DecisionScreen(
                              isReview: false,
                              previousPageIndex: 1,
                              lessonData: null,
                              lessonIndex: 1,
                              subLessonIndex: 0,
                            )));
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  /*static Future<void> showExitExcerciseWarning({required BuildContext context, Function({required BuildContext buildContext})? goToBack}) async {
    bool result = await showDialog(
        context: context,
        useSafeArea: false,
        builder: (ctx) => ShowDialogWidget(
              isActionOptions: true,
              titleText: 'Exiting the exercise screen will erase exercise progress.',
              titleSize: 20,
              subText: "Exit anyways ?",
            ));
    if (result) {
      if (goToBack != null) {
        goToBack(buildContext: context);
      } else {
        changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0)); //not really needed
      }
    }
  }*/

  /*static Widget buildPlaceHolder({required String title}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade500,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Wrap(
          spacing: 4,
          runSpacing: 10,
          children: List<Widget>.generate(10, (index) {
            return Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(color: AppColors.whiteSmoke2),
                child: const Text('Text'));
          }),
        ),
      ]),
    );
  }*/
}
