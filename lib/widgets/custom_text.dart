import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final double? lineHeight;
  final TextDecoration? textDecoration;
  final TextOverflow? overflow;
  final int? maxlines;

  // name constructor that has a positional parameters with the text required
  // and the other parameters optional
  CustomText(
      {required this.text,
      this.size,
      this.color,
      this.weight,
      this.textAlign,
      this.fontFamily,
      this.lineHeight,
      this.textDecoration,
      this.overflow,
      this.maxlines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: size ?? getFontSize(fontSizeMedium, context),
          color: color ?? AppColors.blackColor3,
          fontFamily: fontFamily,
          fontWeight: weight ?? FontWeight.normal,
          height: 1.2, //❌Make sure you are not using the responsive methods here
          decoration: textDecoration),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxlines,
      overflow: overflow,
    );
  }
}
