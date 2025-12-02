import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/models/question_model.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/lesson_completed.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/question_widget.dart';
import 'package:provider/provider.dart';

class ChoiceType extends StatefulWidget {
  final bool isReview;
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  final int exerciseIndex;
  final double exerciseScore;
  final List<double>? exerciseScoreTrackingList; //not used here
  const ChoiceType({
    Key? key,
    required this.isReview,
    required this.snapshot,
    required this.goToNext,
    required this.goToBack,
    required this.lessonData,
    required this.exerciseIndex,
    required this.exerciseScore,
    required this.exerciseScoreTrackingList,
  }) : super(key: key);

  @override
  _ThreeChoiceTypeState createState() => _ThreeChoiceTypeState();
}

class _ThreeChoiceTypeState extends State<ChoiceType> {
  late TextToSpeechProvider textToSpeechProvider;
  int correctAnswerCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    textToSpeechProvider.playPronunciation(widget.snapshot['instruction'].toString());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //bool canGoback = Navigator.canPop(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (x) {
        //AppConstants.showExitExcerciseWarning(context: context, goToBack: widget.goToBack);
        widget.goToBack(buildContext: context);
      },
      child: Scaffold(
        /*appBar: AppBar(
          leading: const SizedBox(),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 0,
        ),*/
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(height: appBarSpace),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).maybePop();
                      },
                      child: Icon(Icons.arrow_back),
                    ),
                    Spacer(),
                    CustomText(
                      text: widget.snapshot['title'],
                      size: getFontSize(18, context),
                      weight: FontWeight.w500,
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              Consumer<TextToSpeechProvider>(builder: (context, tts, child) {
                return AppConstants.buildHeaderUserSound(
                  context: context,
                  icon: tts.playerState == AudioPlayerState.playing
                      ? Image.asset(AppImages.userSound, width: getHorizontalSize(62, context), height: getVerticalSize(50, context))
                      : Padding(
                          padding: const EdgeInsets.only(right: 8, top: 8),
                          child: Image.asset(AppImages.play, width: getHorizontalSize(54, context), height: getVerticalSize(41, context)),
                        ),
                  loading: tts.loading,
                  callBack: () async {
                    if (tts.playerState == AudioPlayerState.playing) {
                      // await textToSpeechProvider.pause();
                    } else if (tts.playerState == AudioPlayerState.paused) {
                      // await textToSpeechProvider.resume();
                    } else {
                      await tts.playPronunciation(widget.snapshot['instruction'].toString());
                    }
                  },
                );
              }),
              SizedBox(height: getVerticalSize(15, context)),
              CustomText(text: widget.snapshot['instruction'], weight: FontWeight.w500),
              SizedBox(height: getVerticalSize(8, context)),
              Expanded(
                child: ListView.separated(
                    padding: EdgeInsets.all(0),
                    itemCount: widget.snapshot['content'].length,
                    itemBuilder: (context, index) {
                      return RepaintBoundary(
                        child: QuestionWidget(
                          key: ValueKey(index),
                          index: index,
                          type: widget.snapshot['type'],
                          isImageQuestion: widget.snapshot['isImageQuestion'],
                          questionModel: QuestionModel.fromMap(widget.snapshot['content'][index], widget.snapshot['type']),
                          callback: (isCorrectOptionSelected) {
                            if (isCorrectOptionSelected) {
                              correctAnswerCount = correctAnswerCount + 1;
                            }
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(height: 10)),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              Consumer<TextToSpeechProvider>(builder: (context, tts, child) {
                return Opacity(
                  opacity: tts.loading ? 0.3 : 1.0,
                  child: CustomButton(
                    text: 'Continue',
                    color: AppColors.buttonColor,
                    onpressed: () {
                      int total = widget.snapshot['content'].length;
                      double score = (correctAnswerCount / total);
                      if (!tts.loading) {
                        tts.stop().then((_) {
                          if (widget.exerciseIndex + 1 >= widget.lessonData.exercises.length) {
                            double totalScore = widget.exerciseScore + score;
                            changeScreenReplacement(
                                context,
                                BottomNavbar(
                                  pageIndex: 1,
                                  newpage: LessonsCompleted(
                                      isReview: widget.isReview, totalScore: totalScore, goToNext: widget.goToNext, lessonData: widget.lessonData),
                                ));
                            DatabaseService.updateLessonProgress(
                              context: context,
                              lessonIndex: widget.lessonData.lessonIndex.toString(),
                              lessonData: widget.lessonData,
                              currentSubLessonIndex: widget.lessonData.subLessons.length,
                              currentExerciseIndex: widget.exerciseIndex + 1,
                              totalLessonIndex: widget.lessonData.subLessons.length + widget.lessonData.exercises.length,
                              score: totalScore,
                              lastUpdateTime: DateTime.now(),
                            );
                          } else {
                            widget.goToNext(buildContext: context, score: score);
                          }
                        });
                      }
                    },
                  ),
                );
              }),
              SizedBox(height: getVerticalSize(15, context)),
            ],
          ),
        ),
      ),
    );
  }
}
