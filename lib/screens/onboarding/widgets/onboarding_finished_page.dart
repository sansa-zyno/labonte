import 'package:flutter/material.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/size_utils.dart';

class OnboardingFinishedPage extends StatelessWidget {
  const OnboardingFinishedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Image.asset(AppImages.success, height: getSize(98, context)),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
