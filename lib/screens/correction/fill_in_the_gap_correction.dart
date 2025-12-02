//import 'dart:developer';
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
import 'package:provider/provider.dart';

class FillInTheGapCorrection extends StatefulWidget {
  final bool isReview;
  final ExerciseCorrection correction;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final LessonData lessonData;
  final int exerciseIndex;
  final double exerciseScore;
  final List<double>? exerciseScoreTrackingList;
  const FillInTheGapCorrection(
      {required this.isReview,
      required this.correction,
      required this.goToNext,
      required this.lessonData,
      required this.exerciseIndex,
      required this.exerciseScore,
      required this.exerciseScoreTrackingList,
      super.key});

  @override
  State<FillInTheGapCorrection> createState() => _FillInTheGapCorrectionState();
}

class _FillInTheGapCorrectionState extends State<FillInTheGapCorrection> {
  bool isLoading = false;
  late TextToSpeechProvider textToSpeechProvider;
  List<String> questions = [];
  List<String> answers = [];
  List<List<TextEditingController>> controllers = [];
  // Controllers for word-all type
  List<List<TextEditingController>> wordAllControllers = [];

  int correctAnswerCount = 0;

  // Cached decoration to prevent recreation
  final _textFieldDecoration1 = const InputDecoration(
    counterText: '',
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
    border: UnderlineInputBorder(),
  );

  // Cached decoration to prevent recreation
  final _textFieldDecoration2 = const InputDecoration(
    counterText: '',
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
    border: UnderlineInputBorder(),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    wordAllControllers = widget.correction.fillInTheGap!.wordAllControllers;
    //
    questions = widget.correction.fillInTheGap!.questions;
    controllers = widget.correction.fillInTheGap!.controllers;
    //
    answers = widget.correction.fillInTheGap!.answers;
    //
    _calculateCorrectAnswers();
  }

  @override
  void dispose() {
    // Clean up all controllers to prevent memory leaks
    //log('dispose() called');
    for (var row in wordAllControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Widget _buildTextField(int rowIndex, int charIndex) {
    return SizedBox(
      width: 15,
      height: 27,
      child: TextField(
        readOnly: true,
        controller: wordAllControllers[rowIndex][charIndex],
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: _textFieldDecoration1,
      ),
    );
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    SizedBox(height: getVerticalSize(15, context)),
                    AppConstants.buildHeaderUserSound(
                      context: context,
                      icon: textToSpeechProvider.playerState == AudioPlayerState.playing
                          ? Image.asset(AppImages.userSound, width: getHorizontalSize(62, context), height: getVerticalSize(50, context))
                          : Padding(
                              padding: const EdgeInsets.only(right: 8, top: 8),
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
                    SizedBox(height: getVerticalSize(15, context)),
                    widget.correction.fillInTheGap!.type.contains('word-all')
                        ? Expanded(
                            flex: 10,
                            child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: wordAllControllers.length,
                                itemBuilder: (ctx, rowIndex) {
                                  String text = '';
                                  for (TextEditingController controller in wordAllControllers[rowIndex]) {
                                    text = text + controller.text;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                                width: 25,
                                                child: CustomText(
                                                    text: '${rowIndex + 1}.', size: getFontSize(16, context), textAlign: TextAlign.center)),
                                            InkWell(
                                                onTap: () {
                                                  textToSpeechProvider.playPronunciation(answers[rowIndex]);
                                                },
                                                child: CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: AppColors.lightGrey3,
                                                    child: Icon(Icons.play_arrow, color: Colors.brown, size: 20))),
                                            SizedBox(width: getHorizontalSize(8, context)),
                                            Wrap(
                                              spacing: 8.0,
                                              runSpacing: 8.0,
                                              children: List.generate(
                                                wordAllControllers[rowIndex].length,
                                                (charIndex) => _buildTextField(rowIndex, charIndex),
                                              ),
                                            ),
                                            Spacer(),
                                            if (isWordAllTypeCorrect(text, answers[rowIndex]))
                                              Icon(Icons.check, color: Colors.green)
                                            else
                                              Icon(Icons.cancel, color: Colors.red)
                                          ],
                                        ),
                                        if (!isWordAllTypeCorrect(text, answers[rowIndex]))
                                          Padding(
                                              padding: const EdgeInsets.only(left: 25, top: 8),
                                              child: Row(children: [
                                                CustomText(text: 'Correct answer is ', color: Colors.black.withOpacity(0.8), weight: FontWeight.w500),
                                                CustomText(text: answers[rowIndex], color: Colors.green, weight: FontWeight.w900)
                                              ]))
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (ctx, index) => const Divider(color: AppColors.lightGrey3, height: 8.0)),
                          )
                        : Expanded(
                            flex: 10,
                            child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.all(0),
                                itemCount: questions.length,
                                itemBuilder: (context, index) {
                                  String text = questions[index];
                                  List<InlineSpan> spans = [];
                                  int controllerIndex = 0;
                                  String finalText = ''; //for word-part
                                  List<String> listOfUserInputs = []; //for sentence
                                  String correctText = ''; //for sentence
                                  //
                                  RegExp blankRegex = RegExp(r'(\b\w’)?\s*_'); // capture optional prefix like m’, s’
                                  Iterable<RegExpMatch> matches = blankRegex.allMatches(text);
                                  //bool answerExistInDB = widget.correction.fillInTheGap!.answers[index].isNotEmpty;
                                  text.splitMapJoin(
                                    RegExp(r'_+'),
                                    onMatch: (m) {
                                      //final blanks = m.group(0)!.length;
                                      String prefix = matches.toList()[controllerIndex].group(1) ?? '';
                                      if (widget.correction.fillInTheGap!.type.contains('sentence')) {
                                        //.trim() to fix extra spaces issue
                                        listOfUserInputs.add('$prefix${controllers[index][controllerIndex].text.trim()}'.toLowerCase());
                                        if (answers.isNotEmpty) {
                                          correctText = correctText + answers[index].split(',')[controllerIndex];
                                        }
                                      } else {
                                        finalText = finalText + controllers[index][controllerIndex].text;
                                      }
                                      spans.add(WidgetSpan(
                                          child: SizedBox(
                                              height: 20,
                                              width: (widget.correction.fillInTheGap!.type.contains('sentence')
                                                  ? ((answers[index].split(',')[controllerIndex].length * 5.0) + 50)
                                                  : 25.0),
                                              child: TextField(
                                                  readOnly: true,
                                                  controller: controllers[index][controllerIndex],
                                                  maxLength: widget.correction.fillInTheGap!.type.contains('sentence')
                                                      ? answers[index].split(',')[controllerIndex].length + 2
                                                      : 1,
                                                  textAlign: widget.correction.fillInTheGap!.type.contains('sentence')
                                                      ? prefix.isNotEmpty
                                                          ? TextAlign.start
                                                          : TextAlign.center
                                                      : TextAlign.center,
                                                  style: const TextStyle(fontSize: 14),
                                                  decoration: _textFieldDecoration2))));
                                      controllerIndex = controllerIndex + 1;
                                      return '';
                                    },
                                    onNonMatch: (text) {
                                      finalText = finalText + text;
                                      correctText = correctText + text;
                                      spans.add(TextSpan(text: text, style: const TextStyle(color: Colors.black)));
                                      return '';
                                    },
                                  );
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 10,
                                              child: RichText(
                                                  text: TextSpan(children: [
                                                WidgetSpan(
                                                    child:
                                                        SizedBox(width: 25, child: CustomText(text: "${index + 1}.", textAlign: TextAlign.center))),
                                                WidgetSpan(
                                                    child: InkWell(
                                                        onTap: () {
                                                          if (widget.correction.fillInTheGap!.type.contains('word-part')) {
                                                            textToSpeechProvider.playPronunciation(answers[index]);
                                                          } else {
                                                            textToSpeechProvider.playPronunciation(correctText);
                                                          }
                                                        },
                                                        child: CircleAvatar(
                                                            radius: 12,
                                                            backgroundColor: AppColors.lightGrey3,
                                                            child: Icon(Icons.play_arrow, color: Colors.brown, size: 20)))),
                                                WidgetSpan(child: SizedBox(width: getHorizontalSize(8, context))),
                                                ...spans,
                                              ])),
                                            ),
                                            Spacer(),
                                            if (widget.correction.fillInTheGap!.type.contains('word-part') &&
                                                isWordPartTypeCorrect(finalText, answers[index]))
                                              Icon(Icons.check, color: Colors.green)
                                            else if (widget.correction.fillInTheGap!.type.contains('sentence') &&
                                                isSentenceTypeCorrect(listOfUserInputs, answers[index]))
                                              Icon(Icons.check, color: Colors.green)
                                            else
                                              Icon(Icons.cancel, color: AppColors.red)
                                          ],
                                        ),
                                        if (widget.correction.fillInTheGap!.type.contains('word-part') &&
                                            !isWordPartTypeCorrect(finalText, answers[index]))
                                          Padding(
                                              padding: const EdgeInsets.only(left: 25, top: 8),
                                              child: Row(children: [
                                                CustomText(text: 'Correct answer is ', color: Colors.black.withOpacity(0.8), weight: FontWeight.w500),
                                                CustomText(text: answers[index], color: Colors.green, weight: FontWeight.w900)
                                              ]))
                                        else if (widget.correction.fillInTheGap!.type.contains('sentence') &&
                                            !isSentenceTypeCorrect(listOfUserInputs, answers[index]))
                                          Padding(
                                              padding: const EdgeInsets.only(left: 5, top: 8),
                                              child: Row(children: [
                                                CustomText(text: 'Correct answer is ', color: Colors.black.withOpacity(0.8), weight: FontWeight.w500),
                                                CustomText(
                                                    text: !answers[index].contains('|') ? answers[index] : answers[index].split('|')[0],
                                                    color: Colors.green,
                                                    weight: FontWeight.w900)
                                              ])),
                                      ]));
                                },
                                separatorBuilder: (ctx, index) => const Divider(color: AppColors.lightGrey3, height: 8.0))),
                    Spacer(flex: 1),
                    Opacity(
                      opacity: textToSpeechProvider.loading ? 0.3 : 1.0,
                      child: CustomButton(
                        text: 'Continue',
                        color: AppColors.buttonColor,
                        onpressed: () {
                          double score = 0;
                          if (widget.correction.fillInTheGap!.type.toString().contains('word-all')) {
                            score = correctAnswerCount / wordAllControllers.length;
                          } else {
                            score = correctAnswerCount / questions.length;
                          }
                          if (!textToSpeechProvider.loading) {
                            textToSpeechProvider.stop().then((_) async {
                              if (widget.exerciseIndex + 1 >= widget.lessonData.exercises.length) {
                                double totalScore = widget.exerciseScore + score;
                                changeScreenReplacement(
                                    context,
                                    BottomNavbar(
                                      pageIndex: 1,
                                      newpage: LessonsCompleted(
                                          isReview: widget.isReview,
                                          totalScore: totalScore,
                                          goToNext: widget.goToNext,
                                          lessonData: widget.lessonData),
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

  void _calculateCorrectAnswers() {
    correctAnswerCount = 0;

    if (widget.correction.fillInTheGap!.type.contains('word-all')) {
      for (int i = 0; i < wordAllControllers.length; i++) {
        String combined = wordAllControllers[i].map((c) => c.text).join();
        if (isWordAllTypeCorrect(combined, answers[i])) {
          correctAnswerCount++;
        }
      }
    } else {
      for (int index = 0; index < questions.length; index++) {
        // Same logic as before, but only run once
        // Build finalText, listOfUserInputs, correctText
        String text = questions[index];
        int controllerIndex = 0;
        String finalText = ''; //for word-part
        List<String> listOfUserInputs = []; //for sentence
        RegExp blankRegex = RegExp(r'(\b\w’)?\s*_'); // capture optional prefix like m’, s’
        Iterable<RegExpMatch> matches = blankRegex.allMatches(text);

        text.splitMapJoin(
          RegExp(r'_+'),
          onMatch: (m) {
            //final blanks = m.group(0)!.length;
            String prefix = matches.toList()[controllerIndex].group(1) ?? '';
            if (widget.correction.fillInTheGap!.type.contains('sentence')) {
              //.trim() to fix extra spaces issue
              listOfUserInputs.add('$prefix${controllers[index][controllerIndex].text.trim()}'.toLowerCase());
            } else {
              finalText = finalText + controllers[index][controllerIndex].text;
            }
            controllerIndex = controllerIndex + 1;
            return '';
          },
          onNonMatch: (text) {
            finalText = finalText + text;
            return '';
          },
        );
        // Then:
        if (widget.correction.fillInTheGap!.type.contains('word-part') && isWordPartTypeCorrect(finalText, answers[index])) {
          correctAnswerCount++;
        } else if (widget.correction.fillInTheGap!.type.contains('sentence') && isSentenceTypeCorrect(listOfUserInputs, answers[index])) {
          correctAnswerCount++;
        }
      }
    }
  }

  bool isWordAllTypeCorrect(String userInput, String answer) {
    return userInput.toLowerCase() == answer.toLowerCase();
  }

  bool isWordPartTypeCorrect(String userInput, String answer) {
    //.replaceAll(' ', '') because spaces exist between '_' following each other
    return userInput.replaceAll(' ', '').toLowerCase() == answer.toLowerCase();
  }

  bool isSentenceTypeCorrect(List<String> listOfUserInputs, String answer) {
    if (answer.isEmpty) {
      return false;
    } else if (!answer.contains('|')) {
      answer = answer.replaceAll('’', '\'');
      String joinedUserInputs = listOfUserInputs.join(',').replaceAll('’', '\'');
      return answer.toLowerCase() == joinedUserInputs;
    } else {
      //Fix for wrong answers due to alternative answers or arrangement
      answer = answer.replaceAll('’', '\'');
      String joinedUserInputs = listOfUserInputs.join(',').replaceAll('’', '\'');
      return answer.toLowerCase().split('|').any((e) => joinedUserInputs == e);
    }
  }

  /*getAIAnswersForEmptyAnswersInDB() async {
    RegExp blankRegex = RegExp(r'(\b\w’)?\s*_'); // capture optional prefix like m’, s’
    try {
      if (widget.correction.fillInTheGap!.type.contains('sentence')) {
        if (widget.correction.fillInTheGap!.answers.every((element) => element == '')) {
          answers = [];
          setState(() {
            isLoading = true;
          });
          for (int i = 0; i < questions.length; i++) {
            int controllerIndex = 0;
            String text = questions[i];
            List<String> listOfUserInputs = []; //for sentence
            Iterable<RegExpMatch> matches = blankRegex.allMatches(text);
            text.splitMapJoin(
              RegExp(r'_+'),
              onMatch: (m) {
                String prefix = matches.toList()[controllerIndex].group(1) ?? '';
                if (controllers[i][controllerIndex].text.trim().isNotEmpty) {
                  listOfUserInputs.add('$prefix${controllers[i][controllerIndex].text.trim()}'.toLowerCase());
                  controllerIndex = controllerIndex + 1;
                }
                return '';
              },
              onNonMatch: (text) {
                return '';
              },
            );
            if (listOfUserInputs.join(',').trim().isNotEmpty) {
              String correctedText = await GeminiService.correctText(listOfUserInputs.join(','));
              answers.add(correctedText); //issue here if result not seperated by comma
            } else {
              answers.add(''); //issue here for more than one gap. out of range error caused by contollerIndex>0
            }
          }
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red[400],
          content: Center(
              child: CustomText(
            text: 'An error occurred',
            color: Colors.white,
          ))));
      setState(() {
        isLoading = false;
      });
    }
  }*/
}
