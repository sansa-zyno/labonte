import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/exercise_correction.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/screens/lesson_completed.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';

class MatchingCorrection extends StatefulWidget {
  final bool isReview;
  final ExerciseCorrection correction;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final LessonData lessonData;
  final int exerciseIndex;
  final double exerciseScore;
  final List<double>? exerciseScoreTrackingList;

  const MatchingCorrection(
      {required this.isReview,
      required this.correction,
      required this.goToNext,
      required this.lessonData,
      required this.exerciseIndex,
      required this.exerciseScore,
      required this.exerciseScoreTrackingList,
      super.key});

  @override
  State<MatchingCorrection> createState() => _MatchingCorrectionState();
}

class _MatchingCorrectionState extends State<MatchingCorrection> {
  late TextToSpeechProvider textToSpeechProvider;
  List<Map<String, dynamic>> questions = [];
  List<String> englishOptions = [];
  Map<int, int> userAnswers = {};

  int correctAnswerCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    questions = widget.correction.matching!.questions;
    englishOptions = widget.correction.matching!.englishOptions;
    userAnswers = widget.correction.matching!.userAnswers;
    _calculateCorrectCount();
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
    //bool canGoback = Navigator.canPop(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (x) {
        //AppConstants.showExitExcerciseWarning(context: context);
        changeScreenReplacement(
            context,
            BottomNavbar(
                pageIndex: 1,
                newpage: DecisionScreen(
                    isReview: widget.isReview,
                    lessonIndex: widget.lessonData.lessonIndex,
                    lessonData: widget.lessonData,
                    subLessonIndex: widget.lessonData.subLessons.length,
                    exerciseIndex: widget.exerciseIndex,
                    exerciseScore: widget.exerciseScore,
                    exerciseScoreTrackingList: widget.exerciseScoreTrackingList,
                    previousPageIndex: 1)));
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: appBarSpace),
              TopBar(
                type: widget.correction.type,
                title: widget.correction.lessonTitle,
                callBack: () {
                  Navigator.of(context).maybePop();
                },
              ),
              SizedBox(height: getVerticalSize(20, context)),
              Expanded(
                flex: 10,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppConstants.buildHeaderUserSound(
                        context: context,
                        icon: textToSpeechProvider.playerState == AudioPlayerState.playing
                            ? Image.asset(AppImages.userSound, width: getHorizontalSize(62, context), height: getVerticalSize(50, context))
                            : Padding(
                                padding: getPadding(context: context, right: 8, top: 8),
                                child: Image.asset(AppImages.play, width: getHorizontalSize(54, context), height: getVerticalSize(41, context)),
                              ),
                        loading: textToSpeechProvider.loading,
                        callBack: () async {
                          if (textToSpeechProvider.playerState == AudioPlayerState.playing) {
                            // await textToSpeechProvider.pause();
                          } else if (textToSpeechProvider.playerState == AudioPlayerState.paused) {
                            // await textToSpeechProvider.resume();
                          } else {
                            await textToSpeechProvider.playPronunciation(widget.correction.lessonInstruction);
                          }
                        },
                      ),
                      SizedBox(height: getVerticalSize(15, context)),
                      CustomText(text: widget.correction.lessonInstruction, weight: FontWeight.w500),
                      SizedBox(height: getVerticalSize(20, context)),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final correctAnswer = questions[index]['english'];
                          final selectedOptionIndex = userAnswers[index];
                          final userAnswer = selectedOptionIndex != null ? englishOptions[selectedOptionIndex] : null;
                          final isCorrect = userAnswer == correctAnswer;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                /// French question
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${index + 1}. ${questions[index]['french']}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const Text('\u2013'),
                                const Spacer(),

                                // ANSWER BOX + Correct Answer Below
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      width: 120, // SAME width as box
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isCorrect ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isCorrect ? Colors.green : Colors.red,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Text(
                                        userAnswer ?? "No answer",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isCorrect ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // CORRECT ANSWER (centered under the box)
                                    if (!isCorrect)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: SizedBox(
                                          width: 120, // EXACT same width as answer box
                                          child: Center(
                                            child: Text(
                                              "$correctAnswer",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              Opacity(
                opacity: textToSpeechProvider.loading ? 0.3 : 1.0,
                child: CustomButton(
                  text: 'Continue',
                  color: AppColors.buttonColor,
                  onpressed: () {
                    double score = correctAnswerCount / questions.length;
                    if (!textToSpeechProvider.loading) {
                      textToSpeechProvider.stop().then((_) {
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
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  _calculateCorrectCount() {
    correctAnswerCount = 0;
    for (int i = 0; i < questions.length; i++) {
      final correctAnswer = questions[i]['english'];
      int? selectedOptionIndex = userAnswers[i];
      final userAnswer = selectedOptionIndex != null ? englishOptions[selectedOptionIndex] : null;
      if (userAnswer == correctAnswer) correctAnswerCount++;
    }
  }
}
