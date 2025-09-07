import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/user.dart';
import 'package:french_app/screens/onboarding/onboarding6.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';

class Onboarding5 extends StatefulWidget {
  final double progressVal;
  final UserModel userModel;
  const Onboarding5({super.key, required this.progressVal, required this.userModel});

  @override
  State<Onboarding5> createState() => _Onboarding5State();
}

class _Onboarding5State extends State<Onboarding5> {
  double progressVal = 0;
  Set selectedVals = {};
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: appBarSpace),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.arrow_back),
                ),
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
                text: 'Select your Learning goals. Choose one or more options',
                size: getFontSize(fontSizeBig, context),
                weight: FontWeight.bold,
              ),
              SizedBox(height: getVerticalSize(15, context)),
              Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection("onboarding").doc("learningGoals").snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.data() != null) {
                          List<dynamic> values = snapshot.data!['values'];
                          return ListView.builder(
                              padding: EdgeInsets.all(0),
                              itemCount: values.length,
                              itemBuilder: (ctx, index) {
                                return GestureDetector(
                                  onTap: () {
                                    if (!selectedVals.contains(values[index])) {
                                      if (selectedVals.isEmpty) {
                                        progressVal = widget.progressVal + 0.16;
                                      }
                                      selectedVals.add(values[index]);
                                      setState(() {});
                                    } else {
                                      if (selectedVals.length == 1) {
                                        progressVal = widget.progressVal + 0.08;
                                      }
                                      selectedVals.remove(values[index]);
                                      setState(() {});
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                    margin: EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                        color: selectedVals.contains(values[index])
                                            ? AppColors.red.withOpacity(0.1)
                                            : AppColors.blackColor1.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: CustomText(text: values[index])),
                                        Visibility(
                                            visible: selectedVals.contains(values[index]),
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
                    onpressed: () {
                      UserModel userModel = widget.userModel.copyWith(learningGoals: List<String>.from(selectedVals));
                      changeScreen(context, Onboarding6(progressVal: progressVal, userModel: userModel));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
