//import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/entitlement.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/models/lesson_progress.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/certificate.dart';
import 'package:french_app/screens/subscription.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class AllLessonsCompleted extends StatefulWidget {
  final double totalScore;
  final Function({required BuildContext buildContext, double? score})? goToNext;
  final LessonData lessonData;
  const AllLessonsCompleted({super.key, required this.totalScore, this.goToNext, required this.lessonData});

  @override
  State<AllLessonsCompleted> createState() => _AllLessonsCompletedState();
}

class _AllLessonsCompletedState extends State<AllLessonsCompleted> {
  ScrollController controller = ScrollController();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _usersCollection = 'users';
  List? lessonsToRetake;
  getUserReviews() async {
    if (DatabaseService.currentUser != null) {
      final snapshot = await _firestore.collection(_usersCollection).doc(DatabaseService.currentUser!.uid).collection('reviews').get();
      lessonsToRetake = snapshot.docs;
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
    });
    getUserReviews();
    //To force update in remote DB because we added a delay of 30 seconds for remote storing in updateLessonProgress()
    LessonProgress lessonProgress = LessonProgress(
      titleInFrench: widget.lessonData.subLessons[0]['title'],
      titleInEnglish: widget.lessonData.subLessons[0]['titleEnglish'],
      currentSubLessonIndex: widget.lessonData.subLessons.length,
      currentExerciseIndex: widget.lessonData.exercises.length,
      totalLessonIndex: widget.lessonData.subLessons.length + widget.lessonData.exercises.length,
      score: widget.totalScore,
      lastUpdateTime: DateTime.now(),
    );
    DatabaseService.updateLessonProgressRemote(false, DatabaseService.currentUser!.uid, widget.lessonData.lessonIndex.toString(), lessonProgress);
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    EntitlementProvider entitlementProvider = Provider.of<EntitlementProvider>(context);
    return Scaffold(
      body: lessonsToRetake == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  children: [
                    SizedBox(height: appBarSpace),
                    Image.asset(AppImages.starBig, height: getSize(286, context)),
                    SizedBox(height: getVerticalSize(30, context)),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Color(0xff151316), borderRadius: BorderRadius.circular(5)),
                      child: CustomText(
                        text: 'You have successfully completed lesson 30',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: getVerticalSize(15, context)),
                    CustomText(
                      text: 'Congratulations! You completed the 30th lesson!',
                      size: getFontSize(20, context),
                      weight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: getVerticalSize(15, context)),
                    lessonsToRetake!.isEmpty
                        ? CustomText(
                            text: 'Great job! You’re making excellent progress in learning French.',
                            textAlign: TextAlign.center,
                          )
                        : CustomText(
                            text:
                                'Great job! You’re making excellent progress in learning French. You still have some lessons in Review section to complete.',
                            textAlign: TextAlign.center,
                          ),
                    SizedBox(height: getVerticalSize(50, context)),
                    CustomButton(
                      width: getHorizontalSize(250, context),
                      text: 'Back to Home',
                      textColor: AppColors.primaryColor,
                      border: Border.all(color: AppColors.primaryColor, width: 1.5),
                      onpressed: () {
                        changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0));
                      },
                    ),
                    SizedBox(height: getVerticalSize(15, context)),
                    lessonsToRetake!.isEmpty
                        ? CustomButton(
                            text: 'View Certificate',
                            color: AppColors.buttonColor,
                            onpressed: () {
                              if (entitlementProvider.entitlement == Entitlement.pro) {
                                changeScreen(context, CertificateScreen(learnerName: appProvider.userModel?.name ?? 'N/A'));
                              } else {
                                changeScreen(context, Subscription());
                              }
                            },
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: getVerticalSize(30, context)),
                  ],
                ),
              ),
            ),
    );
  }
}
