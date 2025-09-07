import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/screens/lessons_completed.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class PuzzleType extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  final int exerciseIndex;
  final double previousExerciseScore;
  const PuzzleType({
    Key? key,
    required this.snapshot,
    required this.goToNext,
    required this.goToBack,
    required this.lessonData,
    required this.exerciseIndex,
    required this.previousExerciseScore,
  }) : super(key: key);
  @override
  State<PuzzleType> createState() => _TablePuzzleTypeState();
}

class _TablePuzzleTypeState extends State<PuzzleType> {
  late TextToSpeechProvider textToSpeechProvider;
  List<String> puzzleRows = [];
  List<String> wordsToFind = [];
  Set<Offset> highlightedCells = {};
  Set<Offset> selectedCells = {};
  Set<String> foundWords = {};
  Offset? startCell;
  String filename = '';

  @override
  void initState() {
    super.initState();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    puzzleRows = List<String>.from(widget.snapshot['content']['question']);
    wordsToFind = List<String>.from(widget.snapshot['content']['answer']);
    textToSpeechProvider.playPronunciation(widget.snapshot['instruction'].toString());
  }

  String getWordFromSelection(Set<Offset> selection) {
    String word = '';
    List<List<String>> grid = puzzleRows.map((row) => row.split('')).toList();
    for (var cell in selection) {
      word += grid[cell.dx.toInt()][cell.dy.toInt()];
    }
    return word;
  }

  bool isValidWordSelection(Set<Offset> selection) {
    if (selection.isEmpty) return false;
    String selectedWord = getWordFromSelection(selection);
    return wordsToFind.contains(selectedWord);
  }

  void handleCellSelection(Offset cellPosition) {
    setState(() {
      if (!selectedCells.contains(cellPosition)) {
        selectedCells.add(cellPosition);
        String currentWord = getWordFromSelection(selectedCells);

        if (isValidWordSelection(selectedCells)) {
          highlightedCells.addAll(selectedCells);
          foundWords.add(currentWord);
          selectedCells = {};
        }
      } else {
        // If tapping an already selected cell, clear selection
        selectedCells = {};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (x) {
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
              /*  // Words to find
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 8,
                  children: wordsToFind.map((word) {
                    bool isFound = foundWords.contains(word);
                    return Chip(
                      label: Text(
                        word,
                        style: TextStyle(
                          decoration: isFound ? TextDecoration.lineThrough : null,
                          color: isFound ? Colors.grey : Colors.black,
                        ),
                      ),
                      backgroundColor: isFound ? Colors.grey.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: getVerticalSize(15, context)),*/

              // Puzzle Grid
              Expanded(
                flex: 10,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(puzzleRows.length, (rowIndex) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(puzzleRows[rowIndex].length, (colIndex) {
                              final position = Offset(rowIndex.toDouble(), colIndex.toDouble());
                              final isHighlighted = highlightedCells.contains(position);
                              final isSelected = selectedCells.contains(position);

                              return GestureDetector(
                                onTap: () => handleCellSelection(position),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.orange
                                        : isHighlighted
                                            ? Colors.lightBlueAccent
                                            : null,
                                    border: Border.all(color: Colors.black54),
                                  ),
                                  child: Text(
                                    puzzleRows[rowIndex][colIndex],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: (isHighlighted || isSelected) ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
              Opacity(
                opacity: textToSpeechProvider.loading ? 0.3 : 1.0,
                child: CustomButton(
                  text: 'Continue',
                  color: AppColors.buttonColor,
                  onpressed: () {
                    checkAnswers().then((x) {
                      double score = foundWords.length / wordsToFind.length;
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
                    });
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

  Future<void> checkAnswers() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Result'),
        content: Text("You got ${foundWords.length} out of ${wordsToFind.length} correct."),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.goToNext(buildContext: context);
              },
              child: Text('Continue')),
        ],
      ),
    );
  }
}
