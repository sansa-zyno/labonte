import 'dart:io';
import 'package:flutter/material.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/widgets/custom_text.dart';

class TopBar extends StatelessWidget {
  final String type;
  final String title;
  final Function callBack;
  const TopBar({required this.type, required this.title, required this.callBack, super.key});

  @override
  Widget build(BuildContext context) {
    return type == 'html-intro'
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  callBack();
                },
                child: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios, size: getSize(20, context)),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              CustomText(
                text: title,
                size: getFontSize(18, context),
                weight: FontWeight.w500,
              ),
            ],
          )
        : Padding(
            padding: getPadding(context: context, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    callBack();
                  },
                  child: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios, size: getSize(20, context)),
                ),
                Spacer(),
                CustomText(
                  text: title,
                  size: getFontSize(18, context),
                  weight: FontWeight.w500,
                ),
                Spacer(),
              ],
            ),
          );
  }
}
