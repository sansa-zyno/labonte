import 'package:flutter/material.dart';

// Viewport values from Figma Design
const double figmaDesignWidth = 375;
const double figmaDesignHeight = 812;

/// Returns the full device size.
Size size(BuildContext context) => MediaQuery.sizeOf(context);

/// Returns the device viewport width.
double width(BuildContext context) => size(context).width;

/// Returns the device viewport height.
double height(BuildContext context) => size(context).height;

/// Returns the status bar height.
double statusBarHeight(BuildContext context) => MediaQuery.of(context).viewPadding.top;

/// Checks if the device is in landscape mode.
bool isLandscape(BuildContext context) => MediaQuery.of(context).orientation == Orientation.landscape;

/// Converts a width value from the Figma design to the responsive width.
double getHorizontalSize(double px, BuildContext context) {
  return (px * width(context)) / (isLandscape(context) ? figmaDesignHeight : figmaDesignWidth);
}

/// Converts a height value from the Figma design to the responsive height.
double getVerticalSize(double px, BuildContext context) {
  return (px * height(context)) / (isLandscape(context) ? figmaDesignWidth : figmaDesignHeight);
}

/// Determines a responsive size for images and other elements.
double getSize(double px, BuildContext context) {
  final double heightSize = getVerticalSize(px, context);
  final double widthSize = getHorizontalSize(px, context);
  return (heightSize + widthSize) / 2; // Averages sizes for better scaling
}

/// Determines a responsive font size.
double getFontSize(double px, BuildContext context) => getSize(px, context);

/// Returns responsive padding.
EdgeInsets getPadding({
  required BuildContext context,
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) =>
    getMarginOrPadding(
      context: context,
      all: all,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );

/// Returns responsive margin.
EdgeInsets getMargin({
  required BuildContext context,
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) =>
    getMarginOrPadding(
      context: context,
      all: all,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );

/// Generates responsive EdgeInsets for margin or padding.
EdgeInsets getMarginOrPadding({
  required BuildContext context,
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) {
  left = all ?? left ?? 0;
  top = all ?? top ?? 0;
  right = all ?? right ?? 0;
  bottom = all ?? bottom ?? 0;

  return EdgeInsets.only(
    left: getHorizontalSize(left, context),
    top: getVerticalSize(top, context),
    right: getHorizontalSize(right, context),
    bottom: getVerticalSize(bottom, context),
  );
}
