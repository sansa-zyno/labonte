import 'package:flutter/material.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final double? textSize;
  final Color textColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Border? border;
  final double? borderRadius;
  final Widget? icon;
  final Function()? onpressed;

  const CustomButton({
    super.key,
    required this.text,
    this.color = Colors.transparent,
    this.textSize,
    this.textColor = Colors.white,
    this.padding,
    this.width,
    this.height,
    this.border,
    this.borderRadius,
    this.icon,
    this.onpressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onpressed,
      child: Container(
        width: width,
        height: height ?? getVerticalSize(52, context),
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(getSize(borderRadius ?? 18, context)),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style:
                  TextStyle(fontSize: textSize ?? getFontSize(fontSizeMedium, context), color: textColor, fontWeight: FontWeight.w400, height: 1.0),
            ),
            if (icon != null) const SizedBox(width: 4),
            if (icon != null) icon!,
          ],
        ),
      ),
    );
  }
}
