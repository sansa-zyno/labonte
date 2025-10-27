//import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/lesson_progress.dart';
import 'package:french_app/models/review.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';

class LessonsCompleted extends StatefulWidget {
  final double totalScore;
  final Function({required BuildContext buildContext, double? score})? goToNext;
  final LessonData lessonData;
  const LessonsCompleted({super.key, required this.totalScore, this.goToNext, required this.lessonData});

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
      maxScore = 1; //Prevent NAN when it's no-exercise type of lesson e.g lesson 26
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
      totalLessonIndex: widget.lessonData.subLessons.length + widget.lessonData.exercises.length,
      score: score,
      lastUpdateTime: DateTime.now(),
    );
    DatabaseService.updateLessonProgressRemote(false, DatabaseService.currentUser!.uid, widget.lessonData.lessonIndex.toString(), lessonProgress);
    if (percentScore < 50) {
      Review review = Review(
          titleInFrench: widget.lessonData.subLessons[0]['title'],
          titleInEnglish: widget.lessonData.subLessons[0]['titleEnglish'],
          lessonId: widget.lessonData.lessonIndex.toString(),
          lastReviewedAt: DateTime.timestamp(),
          reviewCount: 10);
      DatabaseService.addLessonToReviews(DatabaseService.currentUser!.uid, review.lessonId, review);
    } else {
      DatabaseService.removeLessonFromReviews(DatabaseService.currentUser!.uid, widget.lessonData.lessonIndex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              SizedBox(height: appBarSpace),
              Image.asset('assets/images/gif2-nobg.gif', height: getSize(314, context)),
              SizedBox(height: getVerticalSize(15, context)),
              widget.lessonData.exercises.isNotEmpty ? CustomText(text: 'Score: ${percentScore}%', size: 24) : SizedBox.shrink(),
              widget.lessonData.exercises.isNotEmpty ? SizedBox(height: getVerticalSize(15, context)) : SizedBox.shrink(),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Color(0xff5976BA), borderRadius: BorderRadius.circular(5)),
                child: CustomText(
                  text: 'You have successfully completed lesson ${widget.lessonData.lessonIndex}',
                  color: Colors.white,
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
                        TextSpan(text: 'Your overall performance for this lesson is '),
                        TextSpan(
                          style: TextStyle(color: percentScore <= 50 ? AppColors.red4 : AppColors.greenColor, fontWeight: FontWeight.bold),
                          text: percentScore <= 25
                              ? 'Very Poor. '
                              : percentScore <= 50
                                  ? 'Poor. '
                                  : percentScore <= 75
                                      ? 'Great. '
                                      : 'Excellent. ',
                        ),
                        TextSpan(
                            text: percentScore <= 25
                                ? 'We have added this lesson to the review section.'
                                : percentScore <= 50
                                    ? 'We have added this lesson to the review section.'
                                    : percentScore <= 75
                                        ? 'Keep pushing.'
                                        : '')
                      ])),
              SizedBox(height: getVerticalSize(50, context)),
              CustomButton(
                text: 'Continue',
                color: AppColors.buttonColor,
                onpressed: () async {
                  if (widget.lessonData.exercises.isNotEmpty && widget.goToNext != null) {
                    widget.goToNext!(buildContext: context);
                  } else {
                    //Exercises is empty and goToNext is null
                    changeScreenRemoveUntill(
                        context,
                        BottomNavbar(
                          pageIndex: 1,
                          newpage: DecisionScreen(
                              lessonIndex: widget.lessonData.lessonIndex + 1,
                              lessonData: null, //important
                              subLessonIndex: 0,
                              previousPageIndex: 1),
                        ));
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
}
