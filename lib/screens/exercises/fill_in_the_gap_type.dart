import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/exercise_correction.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/screens/correction/fill_in_the_gap_correction.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class FillInTheGapType extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  final int exerciseIndex;
  final double previousExerciseScore;
  const FillInTheGapType({
    required this.snapshot,
    required this.goToNext,
    required this.goToBack,
    required this.lessonData,
    required this.exerciseIndex,
    required this.previousExerciseScore,
    super.key,
  });

  @override
  State<FillInTheGapType> createState() => _FillInTheGapTypeState();
}

class _FillInTheGapTypeState extends State<FillInTheGapType> {
  late TextToSpeechProvider textToSpeechProvider;
  List<String> questions = [];
  List<List<TextEditingController>> controllers = [];
  // Controllers for word-all type
  List<List<TextEditingController>> wordAllControllers = [];

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

  List<String> answers = [];
  List<List<FocusNode>> textFieldFocusNodes = [];
  List<List<FocusNode>> listenerFocusNodes = [];

  @override
  void initState() {
    super.initState();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    if (widget.snapshot['type'].toString().contains('word-all')) {
      // Initialize word-all controllers
      final content = widget.snapshot['content'] as List;
      wordAllControllers = List.generate(
        content.length,
        (i) => List.generate(
          content[i].length,
          (_) => TextEditingController(),
        ),
      );
      listenerFocusNodes = List.generate(
        content.length,
        (i) => List.generate(
          content[i].length,
          (_) => FocusNode(),
        ),
      );
      textFieldFocusNodes = List.generate(
        content.length,
        (i) => List.generate(
          content[i].length,
          (_) => FocusNode(),
        ),
      );
      //answers
      answers = List<String>.from(content);
    } else {
      List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(widget.snapshot['content']);
      for (Map<String, dynamic> map in result) {
        questions.add(map['question']);
        answers.add(map['answer']);
      }
      controllers = [];
      for (var q in questions) {
        int blanks = "_".allMatches(q).length;
        controllers.add(List.generate(blanks, (_) => TextEditingController()));
      }
    }
    textToSpeechProvider.playPronunciation(widget.snapshot['instruction'].toString());
  }

  @override
  void dispose() {
    // Clean up all controllers to prevent memory leaks
    super.dispose();
  }

  Widget _buildTextField(int rowIndex, int charIndex) {
    return SizedBox(
      width: 15,
      height: 27,
      child: KeyboardListener(
        focusNode: listenerFocusNodes[rowIndex][charIndex],
        onKeyEvent: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
            if (wordAllControllers[rowIndex][charIndex].text.isEmpty && charIndex > 0) {
              FocusScope.of(context).requestFocus(textFieldFocusNodes[rowIndex][charIndex - 1]);
            }
          }
        },
        child: TextField(
          controller: wordAllControllers[rowIndex][charIndex],
          focusNode: textFieldFocusNodes[rowIndex][charIndex],
          maxLength: 1,
          textAlign: TextAlign.center,
          decoration: _textFieldDecoration1,
          onChanged: (value) {
            if (value.isNotEmpty && charIndex < wordAllControllers[rowIndex].length - 1) {
              FocusScope.of(context).requestFocus(textFieldFocusNodes[rowIndex][charIndex + 1]);
            }
          },
          textInputAction: charIndex < wordAllControllers[rowIndex].length - 1 ? TextInputAction.next : TextInputAction.done,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (x) async {
        AppConstants.showExitExcerciseWarning(context: context, goToBack: widget.goToBack);
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
                      text: widget.snapshot['title'],
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
                    await textToSpeechProvider.playPronunciation(widget.snapshot['instruction'].toString());
                  }
                },
              ),
              SizedBox(height: getVerticalSize(15, context)),
              CustomText(text: widget.snapshot['instruction'], weight: FontWeight.w500),
              SizedBox(height: getVerticalSize(15, context)),
              widget.snapshot['type'].toString().contains('word-all')
                  ? Expanded(
                      flex: 10,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.snapshot['content'].length,
                        itemBuilder: (ctx, rowIndex) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                    width: 25,
                                    child: CustomText(
                                        text: '${rowIndex + 1}.', size: getFontSize(16, context), lineHeight: 1, textAlign: TextAlign.center)),
                                InkWell(
                                    onTap: () {
                                      textToSpeechProvider.playPronunciation(widget.snapshot['content'][rowIndex]);
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
                                    widget.snapshot['content'][rowIndex].length,
                                    (charIndex) => _buildTextField(rowIndex, charIndex),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Expanded(
                      flex: 10,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          String text = questions[index];
                          List<InlineSpan> spans = [];
                          int controllerIndex = 0;

                          text.splitMapJoin(
                            RegExp(r'_+'),
                            onMatch: (m) {
                              //final blanks = m.group(0)!.length;
                              spans.add(WidgetSpan(
                                child: SizedBox(
                                  height: 20,
                                  width: (widget.snapshot['type'].toString().contains('sentence')
                                      ? ((answers[index].split(',')[controllerIndex].length * 5.0) + 50)
                                      : 25.0),
                                  child: TextField(
                                      controller: controllers[index][controllerIndex],
                                      maxLength: widget.snapshot['type'].toString().contains('sentence')
                                          ? answers[index].split(',')[controllerIndex].length + 2
                                          : 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14),
                                      decoration: _textFieldDecoration2),
                                ),
                              ));
                              controllerIndex = controllerIndex + 1;
                              return '';
                            },
                            onNonMatch: (text) {
                              spans.add(TextSpan(text: text, style: TextStyle(color: Colors.black)));
                              return '';
                            },
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: RichText(
                              text: TextSpan(
                                children: [TextSpan(text: "${index + 1}. ", style: TextStyle(color: Colors.black)), ...spans],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              Spacer(flex: 1),
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
                            fillInTheGap: FillInTheGap(
                              type: widget.snapshot['type'],
                              wordAllControllers: wordAllControllers,
                              questions: questions,
                              controllers: controllers,
                              answers: answers,
                            ));
                        changeScreenReplacement(
                            context,
                            BottomNavbar(
                              pageIndex: 1,
                              newpage: FillInTheGapCorrection(
                                correction: correction,
                                goToNext: widget.goToNext,
                                lessonData: widget.lessonData,
                                exerciseIndex: widget.exerciseIndex,
                                previousExerciseScore: widget.previousExerciseScore,
                              ),
                            ));
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
