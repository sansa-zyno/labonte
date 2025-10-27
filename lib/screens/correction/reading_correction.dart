import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/exercise_correction.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/screens/lesson_completed.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class ReadingCorrection extends StatefulWidget {
  final ExerciseCorrection correction;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final LessonData lessonData;
  final int exerciseIndex;
  final double exerciseScore;
  final List<double>? exerciseScoreTrackingList;
  const ReadingCorrection({
    super.key,
    required this.correction,
    required this.goToNext,
    required this.lessonData,
    required this.exerciseIndex,
    required this.exerciseScore,
    required this.exerciseScoreTrackingList,
  });

  @override
  State<ReadingCorrection> createState() => _ReadingCorrectionState();
}

class _ReadingCorrectionState extends State<ReadingCorrection> {
  late TextToSpeechProvider textToSpeechProvider;

  //Used incase text is not well formatted
  String _normalizePunctuation(String text) {
    // Remove space before punctuation like . , ! ? :
    text = text.replaceAll(RegExp(r'\s+([.,!?;:])'), r'\1');

    // Ensure exactly one space after punctuation (if not end of line)
    text = text.replaceAllMapped(
      RegExp(r'([.,!?;:])(?!\s|$)'),
      (match) => '${match.group(1)} ',
    );

    // Trim leading and trailing spaces
    text = text.trim();

    return text;
  }

  List<TextSpan> _buildColoredText() {
    // First normalize punctuation spacing
    final normalizedPassage = _normalizePunctuation(widget.correction.reading!.passage);
    // Use a regex that separates words and punctuation but keeps them in the list
    final regex = RegExp(r"[\wÀ-ÿ\'’\-]+|[^\wÀ-ÿ\s]");
    final originalTokens = regex.allMatches(normalizedPassage).map((m) => m.group(0)!).toList();

    // Normalize recognized text to words only (no punctuation needed for matching)
    final recognizedWords = widget.correction.reading!.recognizedText
        .replaceAll(RegExp(r"[^\wÀ-ÿ\'’\-]+"), ' ')
        .toLowerCase()
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();
    int index = -1;
    return originalTokens.map((token) {
      // Check if token is punctuation
      final isPunctuation = RegExp(r"[^\wÀ-ÿ\'’\-]").hasMatch(token);

      if (isPunctuation) {
        index++;
        // Always black for punctuation
        return TextSpan(
          text: "$token ",
          style: const TextStyle(color: Colors.black),
        );
      } else {
        index++;
        // Color words depending on recognition
        final isCorrect = recognizedWords.contains(token.toLowerCase());
        return TextSpan(
          text: index == 0 ? token : " $token",
          style: TextStyle(
            color: widget.correction.reading!.recognizedText.isEmpty
                ? Colors.black
                : isCorrect
                    ? Colors.green
                    : Colors.red,
          ),
        );
      }
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
                          double totalScore = widget.exerciseScore + score;
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
