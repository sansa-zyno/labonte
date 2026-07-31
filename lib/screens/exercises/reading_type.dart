import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/exercise_correction.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/provider/stt_provider.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/correction/reading_correction.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class ReadingType extends StatefulWidget {
  final bool isReview;
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  final int exerciseIndex;
  final double exerciseScore;
  final List<double>? exerciseScoreTrackingList; //used in correct screen
  const ReadingType(
      {Key? key,
      required this.isReview,
      required this.snapshot,
      required this.goToNext,
      required this.goToBack,
      required this.lessonData,
      required this.exerciseIndex,
      required this.exerciseScore,
      required this.exerciseScoreTrackingList})
      : super(key: key);

  @override
  State<ReadingType> createState() => _ReadingTypeState();
}

class _ReadingTypeState extends State<ReadingType> {
  late TextToSpeechProvider textToSpeechProvider;
  late SpeechToTextProvider speechToTextProvider;
  String _passage = '';
  String _recognizedText = "";

  int correctCount = 0;
  int totalCount = 0;

  @override
  void initState() {
    super.initState();
    textToSpeechProvider =
        Provider.of<TextToSpeechProvider>(context, listen: false);
    speechToTextProvider =
        Provider.of<SpeechToTextProvider>(context, listen: false);
    _passage = widget.snapshot['content'];
    textToSpeechProvider
        .playPronunciation(widget.snapshot['instruction'].toString());
  }

  void _calculateScore() {
    /*The regex is used to replace any sequence of one or more characters that are 
    NOT letters (including accented ones), digits, underscores, apostrophes, or hyphens 
    with a space ' '*/
    List<String> originalWords = _passage
        .replaceAll(RegExp(r"[^\wÀ-ÿ\'-]+"), ' ')
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();
    List<String> recognizedWords = _recognizedText
        .replaceAll(RegExp(r"[^\wÀ-ÿ\'-]+"), ' ')
        .toLowerCase()
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();
    int correct = 0;
    for (String word in originalWords) {
      if (recognizedWords.contains(word.toLowerCase())) {
        correct++;
      }
    }
    setState(() {
      correctCount = correct;
      totalCount = originalWords.length;
    });
  }

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
    final normalizedPassage = _normalizePunctuation(_passage);
    // Use a regex that separates words and punctuation but keeps them in the list
    final regex = RegExp(r"[\wÀ-ÿ\'’\-]+|[^\wÀ-ÿ\s]");
    final originalTokens =
        regex.allMatches(normalizedPassage).map((m) => m.group(0)!).toList();

    // Normalize recognized text to words only (no punctuation needed for matching)
    final recognizedWords = _recognizedText
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
            color: _recognizedText.isEmpty
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
  Widget build(BuildContext context) {
    speechToTextProvider = Provider.of<SpeechToTextProvider>(context);
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
              TopBar(
                type: widget.snapshot['type'],
                title: widget.snapshot['title'],
                callBack: () {
                  Navigator.of(context).maybePop();
                },
              ),
              SizedBox(height: getVerticalSize(15, context)),
              // Mic
              Center(
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _recognizedText = "";
                      correctCount = 0;
                      totalCount = 0;
                    });
                    String? text =
                        await speechToTextProvider.startSpeechToText();
                    if (text != null) {
                      _recognizedText = text;
                      _calculateScore();
                    }
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        (speechToTextProvider.sttState != STTState.finished &&
                                speechToTextProvider.sttState != STTState.error)
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    child: speechToTextProvider.sttState == STTState.processing
                        ? Center(
                            child:
                                CircularProgressIndicator(color: Colors.green))
                        : speechToTextProvider.sttState == STTState.listening
                            ? RippleAnimation(
                                child: Icon(Icons.mic,
                                    color: Colors.green, size: 50),
                                color: Colors.green.withOpacity(0.1),
                                repeat: true,
                                minRadius: 15,
                                maxRadius: 20,
                                ripplesCount: 6,
                              )
                            : Icon(Icons.mic_none, color: Colors.red, size: 50),
                  ),
                ),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              CustomText(
                  text: widget.snapshot['instruction'],
                  weight: FontWeight.w500),
              SizedBox(height: getVerticalSize(15, context)),
              // Score Display
              Center(
                child: Text("Score: $correctCount / $totalCount",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              // Highlighted paragraph
              Expanded(
                flex: 10,
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      children: _buildColoredText(),
                    ),
                  ),
                ),
              ),

              Spacer(flex: 1),
              Visibility(
                  visible: speechToTextProvider.sttState == STTState.listening,
                  child: Text(
                    'Listening to your speech...',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  )),
              Visibility(
                  visible: speechToTextProvider.sttState == STTState.processing,
                  child: Text(
                    'Processing your speech...',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  )),
              Visibility(
                  visible: speechToTextProvider.sttState == STTState.error,
                  child: Text(
                    'An error occurred, check your network connection...',
                    style: TextStyle(
                        color: AppColors.red,
                        fontSize: 14,
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(height: getVerticalSize(30, context)),
              Opacity(
                opacity: (speechToTextProvider.sttState != STTState.finished &&
                        speechToTextProvider.sttState != STTState.error)
                    ? 0.3
                    : 1.0,
                child: CustomButton(
                  text: 'Continue',
                  color: AppColors.buttonColor,
                  onpressed: () {
                    if (totalCount == 0) {
                      totalCount = 1; //To prevent NaN
                    }
                    if (speechToTextProvider.sttState == STTState.finished ||
                        speechToTextProvider.sttState == STTState.error) {
                      ExerciseCorrection correction = ExerciseCorrection(
                          id: widget.snapshot.id,
                          type: widget.snapshot['type'],
                          lessonTitle:
                              '${widget.snapshot['title']} - Corrections',
                          lessonInstruction: 'Tap audio to play the correction',
                          reading: Reading(
                            passage: _passage,
                            recognizedText: _recognizedText,
                            correctCount: correctCount,
                            totalCount: totalCount,
                            note:
                                'Note: Words pronounced correctly are highlighted green while wrong ones are highlighted red.',
                          ));
                      changeScreenReplacement(
                          context,
                          BottomNavbar(
                            pageIndex: 1,
                            newpage: ReadingCorrection(
                              isReview: widget.isReview,
                              correction: correction,
                              goToNext: widget.goToNext,
                              lessonData: widget.lessonData,
                              exerciseIndex: widget.exerciseIndex,
                              exerciseScore: widget.exerciseScore,
                              exerciseScoreTrackingList:
                                  widget.exerciseScoreTrackingList,
                            ),
                          ));
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
