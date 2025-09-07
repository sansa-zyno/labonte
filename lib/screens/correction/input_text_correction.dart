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
import 'package:french_app/services/gemini_service.dart';
import 'package:french_app/widgets/cached_image.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class InputTextCorrection extends StatefulWidget {
  final ExerciseCorrection correction;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final LessonData lessonData;
  final int exerciseIndex;
  final double previousExerciseScore;
  const InputTextCorrection(
      {required this.correction,
      required this.goToNext,
      required this.lessonData,
      required this.exerciseIndex,
      required this.previousExerciseScore,
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
    getAnswers();
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
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
                          widget.correction.inputText!.type == "list-of-input-text"
                              ? ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: data?.length ?? 0,
                                  shrinkWrap: true,
                                  itemBuilder: (ctx, index) {
                                    if (data![index]['answer'].toString().isNotEmpty &&
                                        answers[index].split(',').contains(controllers[index].text.toLowerCase())) {
                                      correctAnswerCount++;
                                    }
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
                                            if (data![index]['answer'].toString().isNotEmpty &&
                                                answers[index].split(',').contains(controllers[index].text.toLowerCase()))
                                              Icon(Icons.check, color: Colors.green)
                                            else if (data![index]['answer'].toString().isNotEmpty &&
                                                !answers[index].split(',').contains(controllers[index].text.toLowerCase()))
                                              Icon(Icons.cancel, color: AppColors.red)
                                          ]),
                                        ),
                                        //if failed, show correct answer at the bottom
                                        if (data![index]['answer'].toString().isNotEmpty &&
                                            !answers[index].split(',').contains(controllers[index].text.toLowerCase()))
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              CustomText(text: 'Correct answer is ', color: Colors.black.withOpacity(0.8), weight: FontWeight.w500),
                                              Expanded(
                                                  child: CustomText(text: '${data![index]['answer']}', color: Colors.green, weight: FontWeight.w900))
                                            ]),
                                          ),
                                        if (data![index]['answer'].toString().isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              CustomText(text: 'AI Feedback: ', color: AppColors.yellow2, weight: FontWeight.bold),
                                              SizedBox(width: 15),
                                              Expanded(
                                                  child: CustomText(
                                                text: answers.elementAtOrNull(index) != null ? '${answers[index]}' : '',
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
                                                text: answers.elementAtOrNull(0) != null ? '${answers[0]}' : '',
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
                          if (widget.correction.inputText!.type == "list-of-input-text") {
                            score = correctAnswerCount / (data?.length ?? 1);
                          } else {
                            if (answers.isNotEmpty) {
                              /*The regex is used to replace any sequence of one or more characters that are 
                              NOT letters (including accented ones), digits, underscores, apostrophes, or hyphens 
                              with a space ' '*/
                              List<String> userAnswer = oneTextViewController.text
                                  .replaceAll(RegExp(r"[^\wÀ-ÿ\'-]+"), ' ')
                                  .split(' ')
                                  .where((w) => w.trim().isNotEmpty)
                                  .toList();
                              List<String> aiAnswer = answers[0]
                                  .replaceAll(RegExp(r"[^\wÀ-ÿ\'-]+"), ' ')
                                  .toLowerCase()
                                  .split(' ')
                                  .where((w) => w.trim().isNotEmpty)
                                  .toList();
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
                    SizedBox(height: getVerticalSize(30, context)),
                  ],
                ),
              ),
      ),
    );
  }

  getAnswers() async {
    try {
      if (widget.correction.inputText!.type == 'list-of-input-text') {
        if (data!.every((element) => element['answer'] != '')) {
          for (Map map in data!) {
            answers.add(map['answer'].toString().toLowerCase());
          }
        } else {
          //case when it has answer key in data but it is empty because it is a user specific question
          setState(() {
            isLoading = true;
          });
          for (int i = 0; i < controllers.length; i++) {
            if (controllers[i].text != '') {
              if (data![i].containsKey('prefix')) {
                //log('${data![i]['prefix']} ${controllers[i].text}');
                String correctedText = await GeminiService.correctText('Corrige le texte: ${data![i]['prefix']} ${controllers[i].text}');
                answers.add(correctedText);
              } else {
                String correctedText = await GeminiService.correctText('Corrige le texte: ${controllers[i].text}');
                answers.add(correctedText);
              }
            }
          }
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = true;
        });
        if (oneTextViewController.text != '') {
          String correctedText = await GeminiService.correctText('Corrige le texte: ${oneTextViewController.text}');
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
}
