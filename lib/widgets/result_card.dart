/*import 'package:flutter/material.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/widgets/custom_text.dart';

import '../constants/app_colors.dart';

class ResultCard extends StatelessWidget {
  final String pronunciation;
  final String fluency;
  final String accuracy;
  const ResultCard({super.key, required this.pronunciation, required this.fluency, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(color: AppColors.lightGrey3, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: AppColors.yellow2, borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                  child: Center(
                    child: CustomText(
                      text: 'Pronunciation',
                      color: Colors.white,
                      size: fontSizeSmall,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(text: pronunciation),
                    Icon(
                      Icons.check_box,
                      color: Colors.green,
                    )
                  ],
                )
              ],
            ),
          ),
          Spacer(),
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(color: AppColors.lightGrey3, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: AppColors.greenColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                  child: Center(
                    child: CustomText(
                      text: 'Fluency',
                      color: Colors.white,
                      size: fontSizeSmall,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(text: fluency),
                    Icon(
                      Icons.sync,
                      color: Color(0xff5976BA),
                    )
                  ],
                )
              ],
            ),
          ),
          Spacer(),
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(color: AppColors.lightGrey3, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xff5976BA), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                  child: Center(
                    child: CustomText(
                      text: 'Accuracy',
                      color: Colors.white,
                      size: fontSizeSmall,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(text: accuracy),
                    Icon(
                      Icons.close,
                      color: AppColors.red,
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
