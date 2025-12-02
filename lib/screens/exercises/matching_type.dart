import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:french_app/screens/correction/matching_correction.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class MatchingType extends StatefulWidget {
  final bool isReview;
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  final int exerciseIndex;
  final double exerciseScore;
  final List<double>? exerciseScoreTrackingList; //not used here
  const MatchingType({
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
  State<MatchingType> createState() => _MatchingTypeState();
}

class _MatchingTypeState extends State<MatchingType> {
  late TextToSpeechProvider textToSpeechProvider;
  List<Map<String, dynamic>> questions = [];
  List<String> englishOptions = [];
  Map<int, int> userAnswers = {};
  int correctAnswerCount = 0;

  @override
  void initState() {
    super.initState();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    questions = List<Map<String, dynamic>>.from(widget.snapshot['content'])
        .asMap()
        .entries
        .map((entry) => {"id": entry.key.toString(), "french": entry.value['french'], "english": entry.value['english']})
        .toList();
    englishOptions = questions.map((q) => q['english']! as String).toList()..shuffle();
    textToSpeechProvider.playPronunciation(widget.snapshot['instruction'].toString());
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
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
                      text: widget.snapshot['title'],
                      size: getFontSize(18, context),
                      weight: FontWeight.w500,
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: getVerticalSize(10, context)),
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
                            await textToSpeechProvider.playPronunciation(widget.snapshot['instruction'].toString());
                          }
                        },
                      ),
                      SizedBox(height: getVerticalSize(15, context)),
                      CustomText(text: widget.snapshot['instruction'], weight: FontWeight.w500),
                      SizedBox(height: getVerticalSize(20, context)),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final selectedOptionIndex = userAnswers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              Expanded(flex: 2, child: Text("${index + 1}. ${questions[index]['french']}")),
                              const Text('\u2013'),
                              const Spacer(),
                              DragTarget<int>(
                                builder: (context, candidateData, rejectedData) {
                                  return Container(
                                    padding: EdgeInsets.all(3),
                                    width: 120,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Opacity(
                                        opacity: selectedOptionIndex == null ? 0.3 : 1,
                                        child: Text(
                                          selectedOptionIndex != null
                                              ? englishOptions[selectedOptionIndex] // show text by index
                                              : "Drop here",
                                          style: TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        )),
                                  );
                                },
                                onAccept: (data) {
                                  setState(() {
                                    userAnswers[index] = data;
                                  });
                                },
                              ),
                            ]),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: List.generate(
                        englishOptions.length,
                        (index) => Draggable<int>(
                              // use position instead of value to fix issue of greying out other same text
                              // when only one of them is actually dragged
                              data: index,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Chip(label: Text(englishOptions[index])),
                              ),
                              childWhenDragging: Opacity(opacity: 0.3, child: Chip(label: Text(englishOptions[index]))),
                              child: Opacity(
                                  opacity: userAnswers.containsValue(index) ? 0.3 : 1,
                                  child: Chip(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: AppColors.lightGrey),
                                      padding: EdgeInsets.all(0),
                                      label: Text(englishOptions[index]))),
                            ))),
              ),
              SizedBox(height: 15),
              Opacity(
                opacity: textToSpeechProvider.loading ? 0.3 : 1.0,
                child: CustomButton(
                  text: 'Continue',
                  color: AppColors.buttonColor,
                  onpressed: () {
                    if (!textToSpeechProvider.loading) {
                      textToSpeechProvider.stop().then((_) {
                        ExerciseCorrection correction = ExerciseCorrection(
                            id: widget.snapshot.id,
                            lessonTitle: '${widget.snapshot['title']} - Corrections',
                            lessonInstruction: widget.snapshot['instruction'],
                            matching: Matching(questions: questions, englishOptions: englishOptions, userAnswers: userAnswers));
                        changeScreenReplacement(
                            context,
                            BottomNavbar(
                              pageIndex: 1,
                              newpage: MatchingCorrection(
                                isReview: widget.isReview,
                                correction: correction,
                                goToNext: widget.goToNext,
                                lessonData: widget.lessonData,
                                exerciseIndex: widget.exerciseIndex,
                                exerciseScore: widget.exerciseScore,
                                exerciseScoreTrackingList: widget.exerciseScoreTrackingList,
                              ),
                            ));
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
}
