import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';

class OnboardingPage3 extends StatelessWidget {
  final Set selectedVals;
  final Function(Set vals) onSelectionChanged;
  final VoidCallback onContinue;

  const OnboardingPage3({
    super.key,
    required this.selectedVals,
    required this.onSelectionChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: getVerticalSize(15, context)),
          CustomText(
            text:
                'What is your purpose for learning French? Choose one or more options',
            size: getFontSize(fontSizeBig, context),
            weight: FontWeight.bold,
          ),
          SizedBox(height: getVerticalSize(15, context)),
          Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("onboarding")
                      .doc("purposeForLearning")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.data() != null) {
                      List<dynamic> values = snapshot.data!['values'];
                      return ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: values.length,
                          itemBuilder: (ctx, index) {
                            return GestureDetector(
                              onTap: () {
                                Set newVals = Set.from(selectedVals);
                                if (!newVals.contains(values[index])) {
                                  newVals.add(values[index]);
                                } else {
                                  newVals.remove(values[index]);
                                }
                                onSelectionChanged(newVals);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 13),
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    color: selectedVals.contains(values[index])
                                        ? AppColors.red.withValues(alpha: 0.1)
                                        : AppColors.blackColor1
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(text: values[index]),
                                    Visibility(
                                        visible: selectedVals
                                            .contains(values[index]),
                                        child: Icon(
                                          Icons.check,
                                          size: 20,
                                        ))
                                  ],
                                ),
                              ),
                            );
                          });
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })),
          Visibility(
            visible: selectedVals.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 65),
              child: CustomButton(
                text: 'Continue',
                color: AppColors.buttonColor,
                onpressed: onContinue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
