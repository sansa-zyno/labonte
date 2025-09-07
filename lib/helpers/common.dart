import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

void changeScreen(BuildContext context, Widget widget) {
  Navigator.push(context, PageTransition(child: widget, duration: const Duration(milliseconds: 300), type: PageTransitionType.fade));
}

void changeScreenReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(context, PageTransition(child: widget, duration: const Duration(milliseconds: 300), type: PageTransitionType.fade));
}

void changeScreenRemoveUntill(BuildContext context, Widget widget) {
  Navigator.pushAndRemoveUntil(
      context, PageTransition(child: widget, duration: const Duration(milliseconds: 300), type: PageTransitionType.fade), (route) => false);
}

double appBarSpace = 40.0;

double fontSizeExtraSmall = 10;
double fontSizeSmall = 12;
double fontSizeMedium = 14;
double fontSizeBig = 16;
double fontSizeExtraBig = 18;
