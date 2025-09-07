import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/exercise_correction.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/screens/lessons_completed.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class ReadingCorrection extends StatefulWidget {
  final ExerciseCorrection correction;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final LessonData lessonData;
  final int exerciseIndex;
  final double previousExerciseScore;
  const ReadingCorrection({
    super.key,
    required this.correction,
    required this.goToNext,
    required this.lessonData,
    required this.exerciseIndex,
    required this.previousExerciseScore,
  });

  @override
  State<ReadingCorrection> createState() => _ReadingCorrectionState();
}

class _ReadingCorrectionState extends State<ReadingCorrection> {
  late TextToSpeechProvider textToSpeechProvider;

  List<TextSpan> _buildColoredText() {
    List<String> originalWords =
        widget.correction.reading!.passage.replaceAll(RegExp(r"[^\wÀ-ÿ\'-]+"), ' ').split(' ').where((w) => w.trim().isNotEmpty).toList();
    List<String> recognizedWords = widget.correction.reading!.recognizedText
        .replaceAll(RegExp(r"[^\wÀ-ÿ\'-]+"), ' ')
        .toLowerCase()
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();

    return originalWords.map((word) {
      bool isCorrect = recognizedWords.contains(word.toLowerCase());
      return TextSpan(
        text: "$word ",
        style: TextStyle(
          color: widget.correction.reading!.recognizedText.isEmpty
              ? Colors.black
              : isCorrect
                  ? Colors.green
                  : Colors.red,
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (x) {
        AppConstants.showExitExcerciseWarning(context: context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: SizedBox(),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      text: widget.correction.lessonTitle,
                      size: getFontSize(18, context),
                      weight: FontWeight.w500,
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: getVerticalSize(20, context)),
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        textToSpeechProvider.playPronunciation(widget.correction.reading!.passage);
                      },
                      child: Image.asset(AppImages.speaker, height: 20, color: AppColors.primaryColor)),
                  SizedBox(width: 8),
                  CustomText(text: widget.correction.lessonInstruction, weight: FontWeight.w500),
                ],
              ),
              SizedBox(height: getVerticalSize(20, context)),
              // Highlighted paragraph
              Expanded(
                flex: 10,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 16),
                          children: _buildColoredText(),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              Spacer(flex: 1),
              Visibility(
                visible: widget.correction.reading!.note != null,
                child: CustomText(
                  text: widget.correction.reading!.note!,
                  color: Color(0xff5976BA),
                  size: 13,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: getVerticalSize(20, context)),
              Opacity(
                opacity: textToSpeechProvider.loading ? 0.3 : 1.0,
                child: CustomButton(
                  text: 'Continue',
                  color: AppColors.buttonColor,
                  onpressed: () {
                    double score = widget.correction.reading!.correctCount / widget.correction.reading!.totalCount;
                    if (!textToSpeechProvider.loading) {
                      textToSpeechProvider.stop().then((_) {
                        if (widget.exerciseIndex + 1 >= widget.lessonData.exercises.length) {
                          double totalScore = widget.previousExerciseScore + score;
                          changeScreenReplacement(
                              context,
                              BottomNavbar(
                                pageIndex: 1,
                                newpage: LessonsCompleted(totalScore: totalScore, goToNext: widget.goToNext, lessonData: widget.lessonData),
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
              Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
