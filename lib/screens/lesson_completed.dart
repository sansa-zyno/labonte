//import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/entitlement.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/models/lesson_progress.dart';
import 'package:french_app/models/review.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/screens/subscription.dart';
import 'package:french_app/services/ad_service.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class LessonsCompleted extends StatefulWidget {
  final bool isReview;
  final double totalScore;
  final Function({required BuildContext buildContext, double? score})? goToNext;
  final LessonData lessonData;
  const LessonsCompleted(
      {super.key,
      required this.isReview,
      required this.totalScore,
      this.goToNext,
      required this.lessonData});

  @override
  State<LessonsCompleted> createState() => _LessonsCompletedState();
}

class _LessonsCompletedState extends State<LessonsCompleted> {
  ScrollController controller = ScrollController();
  late double score;
  late int maxScore;
  late int percentScore;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
    });
    score = widget.totalScore;
    //log('total score is >>>>>> ${score}');
    maxScore = widget.lessonData.exercises.length;
    if (maxScore == 0) {
      maxScore =
          1; //Prevent NAN when it's no-exercise type of lesson e.g lesson 26
    }
    //log('max score is >>>>>> ${maxScore}');
    percentScore = ((score / maxScore) * 100).round();
    //log('percentage score is >>>>>> ${percentScore}');
    //To force update in remote DB because we added a delay of 30 seconds for remote storing in updateLessonProgress()
    LessonProgress lessonProgress = LessonProgress(
      titleInFrench: widget.lessonData.subLessons[0]['title'],
      titleInEnglish: widget.lessonData.subLessons[0]['titleEnglish'],
      currentSubLessonIndex: widget.lessonData.subLessons.length,
      currentExerciseIndex: widget.lessonData.exercises.length,
      totalLessonIndex: widget.lessonData.subLessons.length +
          widget.lessonData.exercises.length,
      score: score,
      lastUpdateTime: DateTime.now(),
    );
    DatabaseService.updateLessonProgressRemote(
        false,
        DatabaseService.currentUser!.uid,
        widget.lessonData.lessonIndex.toString(),
        lessonProgress);
    if (percentScore < 50) {
      Review review = Review(
          titleInFrench: widget.lessonData.subLessons[0]['title'],
          titleInEnglish: widget.lessonData.subLessons[0]['titleEnglish'],
          lessonId: widget.lessonData.lessonIndex.toString(),
          lastReviewedAt: DateTime.timestamp(),
          reviewCount: 10);
      DatabaseService.addLessonToReviews(
          DatabaseService.currentUser!.uid, review.lessonId, review);
    } else {
      DatabaseService.removeLessonFromReviews(DatabaseService.currentUser!.uid,
          widget.lessonData.lessonIndex.toString());
    }
    // Trigger interstitial at this natural stopping point (lesson completed).
    // Uses addPostFrameCallback so the UI renders before the ad appears,
    // ensuring smooth transition without blocking navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdService>().showInterstitialIfReady();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    EntitlementProvider entitlementProvider =
        Provider.of<EntitlementProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              SizedBox(height: appBarSpace),
              Image.asset('assets/images/gif2-nobg.gif',
                  height: getSize(314, context)),
              SizedBox(height: getVerticalSize(15, context)),
              widget.lessonData.exercises.isNotEmpty
                  ? buildResultCard()
                  : const SizedBox.shrink(),
              widget.lessonData.exercises.isNotEmpty
                  ? SizedBox(height: getVerticalSize(15, context))
                  : const SizedBox.shrink(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xff5976BA),
                    borderRadius: BorderRadius.circular(5)),
                child: CustomText(
                  text:
                      'You have successfully completed lesson ${widget.lessonData.lessonIndex}',
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: TextStyle(
                        color: AppColors.blackColor3,
                        fontWeight: FontWeight.normal,
                        height: getVerticalSize(1.4, context),
                      ),
                      children: [
                        TextSpan(
                          text: percentScore < 50
                              ? 'You are getting there! Let\'s try again to improve your score.'
                              : 'You are doing an amazing job, your hard work is really paying off.',
                        ),
                      ])),
              SizedBox(height: getVerticalSize(30, context)),
              percentScore < 50
                  ? CustomButton(
                      width: getHorizontalSize(250, context),
                      text: 'Repeat Lesson',
                      textColor: AppColors.primaryColor,
                      border:
                          Border.all(color: AppColors.primaryColor, width: 1.5),
                      onpressed: () {
                        changeScreenRemoveUntill(
                            context,
                            BottomNavbar(
                              pageIndex: 1,
                              newpage: DecisionScreen(
                                isReview: widget.isReview,
                                lessonIndex: widget.lessonData.lessonIndex,
                                lessonData: widget.lessonData,
                                subLessonIndex: 0,
                                previousPageIndex: 1,
                              ),
                            ));
                      },
                    )
                  : const SizedBox.shrink(),
              percentScore < 50
                  ? SizedBox(height: getVerticalSize(15, context))
                  : const SizedBox.shrink(),
              CustomButton(
                text: 'Continue',
                color: AppColors.buttonColor,
                onpressed: () async {
                  if (widget.lessonData.exercises.isNotEmpty &&
                      widget.goToNext != null) {
                    widget.goToNext!(buildContext: context);
                  } else {
                    //Exercises is empty and goToNext is null
                    if (entitlementProvider.entitlement == Entitlement.pro) {
                      changeScreenRemoveUntill(
                          context,
                          BottomNavbar(
                            pageIndex: 1,
                            newpage: DecisionScreen(
                                isReview: widget.isReview,
                                lessonIndex: widget.lessonData.lessonIndex + 1,
                                lessonData: null, //important
                                subLessonIndex: 0,
                                previousPageIndex: 1),
                          ));
                    } else {
                      changeScreen(context, Subscription());
                    }
                  }
                },
              ),
              SizedBox(height: getVerticalSize(30, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResultCard() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.lightGrey3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: percentScore < 50 ? Colors.red : Colors.green,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: CustomText(
              text: 'Score',
              color: Colors.white,
              size: fontSizeSmall,
              lineHeight: 1.0,
            ),
          ),
          // Use Expanded to take the rest of the space and center text perfectly
          Expanded(
            child: Center(
              child: CustomText(
                text: '$percentScore%',
                size: fontSizeBig,
                lineHeight: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
