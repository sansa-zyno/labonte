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
import 'package:french_app/services/gemini_service.dart';
import 'package:french_app/widgets/cached_image.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';

class InputTextCorrection extends StatefulWidget {
  final bool isReview;
  final ExerciseCorrection correction;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final LessonData lessonData;
  final int exerciseIndex;
  final double exerciseScore;
  final List<double>? exerciseScoreTrackingList;
  const InputTextCorrection(
      {required this.isReview,
      required this.correction,
      required this.goToNext,
      required this.lessonData,
      required this.exerciseIndex,
      required this.exerciseScore,
      required this.exerciseScoreTrackingList,
      super.key});

  @override
  State<InputTextCorrection> createState() => _InputTextCorrectionState();
}

class _InputTextCorrectionState extends State<InputTextCorrection> {
  bool isLoading = false;
  late TextToSpeechProvider textToSpeechProvider;
  List<Map>? data;
  List<TextEditingController> controllers = [];
  //
  TextEditingController oneTextViewController = TextEditingController();

  int correctAnswerCount = 0;

  // Cached decoration to prevent recreation
  final _textFieldDecoration = const InputDecoration(
    counterText: '',
    isDense: true,
    contentPadding: EdgeInsets.only(left: 15),
    border: UnderlineInputBorder(),
  );

  List<String> answers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    data = widget.correction.inputText!.data;
    //
    oneTextViewController = widget.correction.inputText!.oneTextViewController;
    //
    controllers = widget.correction.inputText!.controllers;
    getAnswers().then((x) {
      _calculateCorrectAnswers();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // Clean up all controllers to prevent memory leaks
    for (var controller in controllers) {
      controller.dispose();
    }
    oneTextViewController.dispose();
    super.dispose();
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
                    SizedBox(height: getVerticalSize(15, context)),
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
                    if (widget.correction.lessonInstruction.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CustomText(text: widget.correction.lessonInstruction, weight: FontWeight.w500),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (widget.correction.inputText!.images != null && widget.correction.inputText!.images!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: widget.correction.inputText!.images!.map((item) {
                                    int noImages = widget.correction.inputText!.images!.length;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CachedImage(item['img'],
                                              height: noImages == 1
                                                  ? 150
                                                  : noImages <= 3
                                                      ? 70
                                                      : 50,
                                              fit: BoxFit.cover),
                                          if (item['name'].toString().isNotEmpty) SizedBox(height: 3),
                                          if (item['name'].toString().isNotEmpty) CustomText(text: item['name'])
                                        ],
                                      ),
                                    );
                                  }).toList()),
                            ),
                          widget.correction.type == "list-of-input-text"
                              ? ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: data?.length ?? 0,
                                  shrinkWrap: true,
                                  itemBuilder: (ctx, index) {
                                    bool answerExistInDB = data![index]['answer'].toString().isNotEmpty;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if ((data![index] as Map<String, dynamic>).containsKey('question') &&
                                            data![index]['question'].toString().isNotEmpty)
                                          !data![index]['question'].toString().startsWith('https://')
                                              ? CustomText(text: '${index + 1}. ${data![index]['question']}')
                                              : Row(
                                                  children: [
                                                    CustomText(text: '${index + 1}.'),
                                                    SizedBox(width: getHorizontalSize(8, context)),
                                                    CachedImage(data![index]['question'], height: 50, fit: BoxFit.cover),
                                                  ],
                                                ),
                                        if ((data![index] as Map<String, dynamic>).containsKey('image') &&
                                            data![index]['image'].toString().isNotEmpty)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: getVerticalSize(8, context)),
                                              CachedImage(
                                                data![index]['image'],
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            ],
                                          ),
                                        if ((data![index] as Map<String, dynamic>).containsKey('qtranslation') &&
                                            data![index]['qtranslation'].toString().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15, top: 1),
                                            child: CustomText(text: data![index]['qtranslation']),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Row(children: [
                                            if ((data![index] as Map<String, dynamic>).containsKey('prefix') &&
                                                data![index]['prefix'].toString().isNotEmpty) //prefix
                                              CustomText(text: data![index]['prefix']),
                                            SizedBox(width: getHorizontalSize(5, context)),
                                            Expanded(
                                              child: TextField(
                                                  readOnly: true, controller: controllers[index], maxLines: 1, decoration: _textFieldDecoration),
                                            ),
                                            SizedBox(width: getHorizontalSize(15, context)),
                                            //check or cancel mark at right hand side
                                            if (answerExistInDB && isListOfInputTypeCorrect(controllers[index].text, answers[index]))
                                              Icon(Icons.check, color: Colors.green)
                                            else if (answerExistInDB && !isListOfInputTypeCorrect(controllers[index].text, answers[index]))
                                              Icon(Icons.cancel, color: AppColors.red)
                                          ]),
                                        ),
                                        //if failed, show correct answer at the bottom
                                        if (answerExistInDB && !isListOfInputTypeCorrect(controllers[index].text, answers[index]))
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              CustomText(text: 'Correct answer is ', color: Colors.black.withOpacity(0.8), weight: FontWeight.w500),
                                              Expanded(
                                                  child: CustomText(
                                                      text: data![index]['answer'].toString().split(',')[0],
                                                      color: Colors.green,
                                                      weight: FontWeight.w900))
                                            ]),
                                          ),
                                        if (!answerExistInDB && !isListOfInputTypeCorrect(controllers[index].text, answers[index]))
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              CustomText(text: 'AI Feedback: ', color: AppColors.yellow2, weight: FontWeight.bold),
                                              SizedBox(width: 15),
                                              Expanded(
                                                  child: CustomText(
                                                text: answers.elementAtOrNull(index) != null ? answers[index] : '',
                                                color: Colors.green,
                                                weight: FontWeight.w900,
                                              ))
                                            ]),
                                          )
                                      ],
                                    );
                                  },
                                  separatorBuilder: (ctx, index) => Divider(color: AppColors.lightGrey3),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        readOnly: true,
                                        minLines: 1,
                                        maxLines: 5,
                                        controller: oneTextViewController,
                                        decoration: _textFieldDecoration.copyWith(contentPadding: EdgeInsets.all(0)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          CustomText(text: 'AI Feedback: ', color: AppColors.yellow2, weight: FontWeight.bold),
                                          SizedBox(width: 15),
                                          Expanded(
                                            child: CustomText(
                                                text: answers.elementAtOrNull(0) != null ? answers[0] : '',
                                                color: Colors.green,
                                                weight: FontWeight.w900),
                                          )
                                        ]),
                                      )
                                    ],
                                  ),
                                ),
                        ]),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(15, context)),
                    Opacity(
                      opacity: textToSpeechProvider.loading ? 0.3 : 1.0,
                      child: CustomButton(
                        text: 'Ok, got it',
                        color: AppColors.buttonColor,
                        onpressed: () {
                          double score = 0;
                          if (widget.correction.type == "list-of-input-text") {
                            score = correctAnswerCount / (data?.length ?? 1);
                          } else {
                            if (answers.isNotEmpty) {
                              List<String> userAnswer = normalizeAndSplitText(oneTextViewController.text);
                              List<String> aiAnswer = normalizeAndSplitText(answers[0]);
                              int correct = 0;
                              for (String word in userAnswer) {
                                if (aiAnswer.contains(word.toLowerCase())) {
                                  correct++;
                                }
                              }
                              double result = correct / aiAnswer.length;
                              if (result <= 0) {
                                score = 0.0;
                              } else if (result > 0 && result <= 0.25) {
                                score = 0.25;
                              } else if (result > 0.25 && result <= 0.5) {
                                score = 0.5;
                              } else if (result > 0.5 && result <= 0.75) {
                                score = 0.75;
                              } else {
                                score = 1.0;
                              }
                            }
                          }
                          if (!textToSpeechProvider.loading) {
                            textToSpeechProvider.stop().then((_) {
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
                    SizedBox(height: getVerticalSize(30, context)),
                  ],
                ),
              ),
      ),
    );
  }

  void _calculateCorrectAnswers() {
    correctAnswerCount = 0;
    if (widget.correction.type == "list-of-input-text") {
      for (int i = 0; i < controllers.length; i++) {
        if (isListOfInputTypeCorrect(controllers[i].text, answers[i])) {
          correctAnswerCount++;
        }
      }
    }
  }

  bool isListOfInputTypeCorrect(String userInput, String answer) {
    if (userInput.isEmpty || answer.isEmpty) {
      return false;
    } else {
      //Case 1: if answer exist in db, it can be one text or alternatives seperated by a comma
      //Case 2: if answer doesn't exist in db, then is AI answer
      answer = answer.replaceAll('’', '\'');
      userInput = userInput.replaceAll('’', '\'');
      return answer.toLowerCase().split(',').contains(userInput.toLowerCase().trim()) ||
          answer.toLowerCase().contains(userInput.toLowerCase().trim());
    }
  }

  Future<void> getAnswers() async {
    try {
      if (widget.correction.type == 'list-of-input-text') {
        //case 1
        if (data!.every((element) => element['answer'] != '')) {
          for (Map map in data!) {
            answers.add(map['answer']);
          }
        }
        //case 2: when it has answer key in data but it is empty because it is a user specific question
        else {
          setState(() {
            isLoading = true;
          });
          for (int i = 0; i < controllers.length; i++) {
            if (controllers[i].text != '') {
              if (data![i].containsKey('prefix')) {
                //log('${data![i]['prefix']} ${controllers[i].text}');
                String correctedText = await GeminiService.correctText('${data![i]['prefix']} ${controllers[i].text}');
                answers.add(correctedText);
              } else {
                String correctedText = await GeminiService.correctText(controllers[i].text);
                answers.add(correctedText);
              }
            } else {
              answers.add('');
            }
          }
          setState(() {
            isLoading = false;
          });
        }
      }
      //case 3:
      else {
        setState(() {
          isLoading = true;
        });
        if (oneTextViewController.text != '') {
          String correctedText = await GeminiService.correctText(oneTextViewController.text);
          answers.add(correctedText);
        }
        setState(() {
          isLoading = false;
        });
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
  }

  List<String> normalizeAndSplitText(String text) {
    /*The regex is used to replace any sequence of one or more characters that are 
    NOT letters (including accented ones), digits, underscores, apostrophes, or hyphens 
    with a space ' '*/
    final listOfString = text.replaceAll(RegExp(r"[^\wÀ-ÿ\'-]+"), ' ').split(' ').where((w) => w.trim().isNotEmpty).toList();
    return listOfString;
  }
}
