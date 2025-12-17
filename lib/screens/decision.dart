//import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/models/entitlement.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/models/lesson_progress.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:french_app/screens/all_lessons_completed.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/exercises/choice_type.dart';
import 'package:french_app/screens/exercises/fill_in_the_gap_type.dart';
import 'package:french_app/screens/exercises/input_text_type.dart';
import 'package:french_app/screens/exercises/matching_type.dart';
import 'package:french_app/screens/exercises/puzzle_type.dart';
import 'package:french_app/screens/exercises/reading_type.dart';
import 'package:french_app/screens/lesson_completed.dart';
import 'package:french_app/screens/lessons/alpha_numeric_type.dart';
import 'package:french_app/screens/lessons/conversation_type.dart';
import 'package:french_app/screens/lessons/image_type.dart';
import 'package:french_app/screens/lessons/list_type.dart';
import 'package:french_app/screens/lessons/html_page.dart';
import 'package:french_app/screens/lessons/sentence_meaning.dart';
import 'package:french_app/screens/lessons/table_type.dart';
import 'package:french_app/screens/lessons/tree_type.dart';
import 'package:french_app/screens/subscription.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/services/local_storage.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class DecisionScreen extends StatefulWidget {
  final bool isReview;
  final int lessonIndex;
  final int subLessonIndex;
  final int? exerciseIndex;
  final double? exerciseScore;
  final List<double>? exerciseScoreTrackingList;
  final LessonData? lessonData;
  final int previousPageIndex;

  const DecisionScreen({
    required this.isReview,
    required this.lessonIndex,
    required this.subLessonIndex,
    this.exerciseIndex,
    this.exerciseScore,
    this.exerciseScoreTrackingList,
    this.lessonData,
    required this.previousPageIndex,
    super.key,
  });

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  bool loading = false;
  DocumentSnapshot? data;
  late LessonData lessonData;
  late EntitlementProvider entitlementProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    entitlementProvider = Provider.of<EntitlementProvider>(context, listen: false);
    //log('exercise score  ${widget.exerciseScore?.toString() ?? '0'}');
    if (widget.lessonData == null) {
      startLessonFlow(widget.lessonIndex);
    } else {
      lessonData = widget.lessonData!;
    }
    setContinueLessonProgress();
    Provider.of<AppProvider>(context, listen: false).isReview = widget.isReview;
    Provider.of<AppProvider>(context, listen: false).continueSubLessonIndex = widget.subLessonIndex;
    Provider.of<AppProvider>(context, listen: false).continueExerciseIndex = widget.exerciseIndex;
  }

  setContinueLessonProgress() async {
    await LocalStorage().setBool('isReview', widget.isReview);
    await LocalStorage().setString('continueLessonIndex', '${widget.lessonIndex}');
    await LocalStorage().setString('continueSubLessonIndex', '${widget.subLessonIndex}');
    await LocalStorage().setString('continueExerciseIndex', '${widget.exerciseIndex}');
  }

  void startLessonFlow(int lessonIndex) async {
    loading = true;
    setState(() {});
    final firestore = FirebaseFirestore.instance;
    final lessonName = 'Lesson$lessonIndex';
    final subLessons = (await firestore.collection(lessonName).get()).docs;
    subLessons.removeWhere((doc) => doc.id == 'exercises');
    subLessons.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    final exercises = (await firestore.collection(lessonName).doc('exercises').collection('exercises').get()).docs;
    exercises.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    lessonData = LessonData(
      lessonIndex: lessonIndex,
      subLessons: subLessons,
      exercises: exercises,
    );
    loading = false;
    setState(() {});
    Provider.of<AppProvider>(context, listen: false).continueLessonData = lessonData;
    //Initialize or resets the lesson progress in remote database only
    if (DatabaseService.currentUser != null && lessonData.subLessons.isNotEmpty) {
      LessonProgress lessonProgress = LessonProgress(
        titleInFrench: lessonData.subLessons[0]['title'],
        titleInEnglish: lessonData.subLessons[0]['titleEnglish'],
        currentSubLessonIndex: 0,
        currentExerciseIndex: null,
        totalLessonIndex: lessonData.subLessons.length + lessonData.exercises.length,
        score: 0,
        lastUpdateTime: DateTime.now(),
      );
      DatabaseService.updateLessonProgressRemote(true, DatabaseService.currentUser!.uid, lessonData.lessonIndex.toString(), lessonProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      if (widget.subLessonIndex < lessonData.subLessons.length) {
        data = lessonData.subLessons[widget.subLessonIndex];
      } else if ((widget.exerciseIndex ?? 0) < lessonData.exercises.length) {
        data = lessonData.exercises[widget.exerciseIndex ?? 0];
      } else if (lessonData.lessonIndex == 26 || lessonData.lessonIndex == 30) {
        //no exercises//show last sublesson
        data = lessonData.subLessons[widget.subLessonIndex - 1];
      } /*else if (widget.subLessonIndex == lessonData.subLessons.length && widget.exerciseIndex == lessonData.exercises.length) {
        //Lesson has already been completed so we start lesson again
        data = lessonData.subLessons[0];
      }*/
    }

    return loading
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : data != null
            ? data!['type'] == 'alphabet' || data!['type'] == 'numeric'
                ? AlphaNumericType(snapshot: data!, goToNext: goToNext, goToBack: goToBack, lessonData: lessonData)
                : data!['type'] == 'list'
                    ? ListType(snapshot: data!, goToNext: goToNext, goToBack: goToBack, lessonData: lessonData)
                    : data!['type'].toString().toLowerCase().contains('image')
                        ? ImageType(snapshot: data!, goToNext: goToNext, goToBack: goToBack, lessonData: lessonData)
                        : data!['type'].toString().toLowerCase().contains('table')
                            ? TableType(snapshot: data!, goToNext: goToNext, goToBack: goToBack, lessonData: lessonData)
                            : data!['type'].toString().toLowerCase().contains('html')
                                ? HTMLPage(snapshot: data!, goToNext: goToNext, goToBack: goToBack, lessonData: lessonData)
                                : data!['type'] == 'sentence-meaning'
                                    ? SentenceMeaning(snapshot: data!, goToNext: goToNext, goToBack: goToBack, lessonData: lessonData)
                                    : data!['type'] == 'tree'
                                        ? TreeType(snapshot: data!, goToNext: goToNext, goToBack: goToBack, lessonData: lessonData)
                                        : data!['type'] == 'conversation'
                                            ? ConversationType(snapshot: data!, goToNext: goToNext, goToBack: goToBack, lessonData: lessonData)
                                            : data!['type'].toString().contains('input-text')
                                                ? InputTextType(
                                                    isReview: widget.isReview,
                                                    snapshot: data!,
                                                    goToNext: goToNext,
                                                    goToBack: goToBack,
                                                    lessonData: lessonData,
                                                    exerciseIndex: widget.exerciseIndex!,
                                                    exerciseScore: widget.exerciseScore ?? 0,
                                                    exerciseScoreTrackingList: widget.exerciseScoreTrackingList ?? [],
                                                  )
                                                : data!['type'].toString().toLowerCase().contains('fill-in-the-gap')
                                                    ? FillInTheGapType(
                                                        isReview: widget.isReview,
                                                        snapshot: data!,
                                                        goToNext: goToNext,
                                                        goToBack: goToBack,
                                                        lessonData: lessonData,
                                                        exerciseIndex: widget.exerciseIndex!,
                                                        exerciseScore: widget.exerciseScore ?? 0,
                                                        exerciseScoreTrackingList: widget.exerciseScoreTrackingList ?? [],
                                                      )
                                                    : data!['type'] == 'reading'
                                                        ? ReadingType(
                                                            isReview: widget.isReview,
                                                            snapshot: data!,
                                                            goToNext: goToNext,
                                                            goToBack: goToBack,
                                                            lessonData: lessonData,
                                                            exerciseIndex: widget.exerciseIndex!,
                                                            exerciseScore: widget.exerciseScore ?? 0,
                                                            exerciseScoreTrackingList: widget.exerciseScoreTrackingList ?? [],
                                                          )
                                                        : data!['type'].toString().toLowerCase().contains('choice')
                                                            ? ChoiceType(
                                                                isReview: widget.isReview,
                                                                snapshot: data!,
                                                                goToNext: goToNext,
                                                                goToBack: goToBack,
                                                                lessonData: lessonData,
                                                                exerciseIndex: widget.exerciseIndex!,
                                                                exerciseScore: widget.exerciseScore ?? 0,
                                                                exerciseScoreTrackingList: widget.exerciseScoreTrackingList ?? [],
                                                              )
                                                            : data!['type'] == 'puzzle'
                                                                ? PuzzleType(
                                                                    isReview: widget.isReview,
                                                                    snapshot: data!,
                                                                    goToNext: goToNext,
                                                                    goToBack: goToBack,
                                                                    lessonData: lessonData,
                                                                    exerciseIndex: widget.exerciseIndex!,
                                                                    exerciseScore: widget.exerciseScore ?? 0,
                                                                    exerciseScoreTrackingList: widget.exerciseScoreTrackingList ?? [],
                                                                  )
                                                                : data!['type'] == 'matching'
                                                                    ? MatchingType(
                                                                        isReview: widget.isReview,
                                                                        snapshot: data!,
                                                                        goToNext: goToNext,
                                                                        goToBack: goToBack,
                                                                        lessonData: lessonData,
                                                                        exerciseIndex: widget.exerciseIndex!,
                                                                        exerciseScore: widget.exerciseScore ?? 0,
                                                                        exerciseScoreTrackingList: widget.exerciseScoreTrackingList ?? [],
                                                                      )
                                                                    : Scaffold(
                                                                        body: Center(
                                                                            child: CustomText(text: 'No match available for this lesson type')))
            : Scaffold(body: Center(child: CustomText(text: 'Data not available for this lesson. Check your network connection')));
  }

  // Go to the next sub-lesson or exercise
  void goToNext({required BuildContext buildContext, double? score}) async {
    if (widget.lessonIndex != 1 && entitlementProvider.entitlement != Entitlement.pro) {
      changeScreen(buildContext, Subscription());
      return;
    }
    if (widget.subLessonIndex + 1 < lessonData.subLessons.length) {
      // Go to next sub-lesson
      changeScreen(
          buildContext,
          BottomNavbar(
              pageIndex: widget.previousPageIndex,
              newpage: DecisionScreen(
                  isReview: widget.isReview,
                  lessonIndex: widget.lessonIndex,
                  lessonData: lessonData,
                  subLessonIndex: widget.subLessonIndex + 1,
                  previousPageIndex: widget.previousPageIndex)));
      DatabaseService.updateLessonProgress(
        context: buildContext,
        lessonIndex: lessonData.lessonIndex.toString(),
        lessonData: lessonData,
        currentSubLessonIndex: widget.subLessonIndex + 1,
        currentExerciseIndex: null,
        totalLessonIndex: lessonData.subLessons.length + lessonData.exercises.length,
        score: 0,
        lastUpdateTime: DateTime.now(),
      );
    } else if (widget.subLessonIndex + 1 == lessonData.subLessons.length) {
      if (lessonData.exercises.isNotEmpty) {
        // Go to exercise
        changeScreen(
            buildContext,
            BottomNavbar(
                pageIndex: widget.previousPageIndex,
                newpage: DecisionScreen(
                    isReview: widget.isReview,
                    lessonIndex: widget.lessonIndex,
                    lessonData: lessonData,
                    subLessonIndex: widget.subLessonIndex + 1,
                    exerciseIndex: 0,
                    //exerciseScore at first exercise screen is 0
                    exerciseScore: 0,
                    previousPageIndex: widget.previousPageIndex)));
        DatabaseService.updateLessonProgress(
          context: buildContext,
          lessonIndex: lessonData.lessonIndex.toString(),
          lessonData: lessonData,
          currentSubLessonIndex: widget.subLessonIndex + 1,
          currentExerciseIndex: 0,
          totalLessonIndex: lessonData.subLessons.length + lessonData.exercises.length,
          score: 0,
          lastUpdateTime: DateTime.now(),
        );
      } else {
        //Lesson doesn't have exercise, so go to lesson completed page
        if (lessonData.lessonIndex + 1 <= 30) {
          changeScreen(
              context, BottomNavbar(pageIndex: 1, newpage: LessonsCompleted(isReview: widget.isReview, totalScore: 1, lessonData: lessonData)));
        } else {
          changeScreen(context, BottomNavbar(pageIndex: 1, newpage: AllLessonsCompleted(totalScore: 1, lessonData: lessonData)));
        }
      }
    } else if (widget.exerciseIndex! + 1 < lessonData.exercises.length) {
      // Go to next exercise // Single activity screen
      changeScreen(
          buildContext,
          BottomNavbar(
              pageIndex: widget.previousPageIndex,
              newpage: DecisionScreen(
                  isReview: widget.isReview,
                  lessonIndex: widget.lessonIndex,
                  lessonData: lessonData,
                  subLessonIndex: widget.subLessonIndex,
                  exerciseIndex: widget.exerciseIndex! + 1,
                  //exerciseScore is sum of exercise scores up to that exercise
                  //score is the true score of a particular exercise
                  exerciseScore: (widget.exerciseScore ?? 0) + (score ?? 0),
                  exerciseScoreTrackingList: () {
                    List<double> exerciseScoreTrackingList = widget.exerciseScoreTrackingList ?? [];
                    exerciseScoreTrackingList.add(score ?? 0);
                    return exerciseScoreTrackingList;
                  }(),
                  previousPageIndex: widget.previousPageIndex)));
      DatabaseService.updateLessonProgress(
        context: buildContext,
        lessonIndex: lessonData.lessonIndex.toString(),
        lessonData: lessonData,
        currentSubLessonIndex: widget.subLessonIndex,
        currentExerciseIndex: widget.exerciseIndex! + 1,
        totalLessonIndex: lessonData.subLessons.length + lessonData.exercises.length,
        score: (widget.exerciseScore ?? 0) + (score ?? 0),
        lastUpdateTime: DateTime.now(),
      );
    } else {
      if (!widget.isReview) {
        // All exercises done, go to next lesson
        if (lessonData.lessonIndex + 1 <= 30) {
          changeScreenRemoveUntill(
              buildContext,
              BottomNavbar(
                pageIndex: widget.previousPageIndex,
                newpage: DecisionScreen(
                    isReview: widget.isReview,
                    lessonIndex: widget.lessonIndex + 1,
                    lessonData: null, //important
                    subLessonIndex: 0,
                    previousPageIndex: widget.previousPageIndex),
              ));
        } else {
          changeScreen(context, BottomNavbar(pageIndex: 1, newpage: AllLessonsCompleted(totalScore: 1, lessonData: lessonData)));
        }
      } else {
        final userId = DatabaseService.currentUser!.uid;
        const int totalLessons = 30;
        const double passMark = 50.0; //percent

        final nextLessonIndex = await DatabaseService.findNextUnpassedLesson(
          userId: userId,
          currentLessonIndex: lessonData.lessonIndex,
          maxScore: lessonData.exercises.length,
          totalLessons: totalLessons,
          passMark: passMark,
        );

        if (nextLessonIndex != null) {
          changeScreenRemoveUntill(
            buildContext,
            BottomNavbar(
              pageIndex: widget.previousPageIndex,
              newpage: DecisionScreen(
                  isReview: widget.isReview,
                  lessonIndex: nextLessonIndex,
                  lessonData: null, // important for reload
                  subLessonIndex: 0,
                  previousPageIndex: widget.previousPageIndex),
            ),
          );
        } else {
          // All lessons passed
          changeScreen(
            context,
            BottomNavbar(
              pageIndex: 1,
              newpage: AllLessonsCompleted(totalScore: 1, lessonData: lessonData),
            ),
          );
        }
      }
    }
  }

  // Go back to the previous sub-lesson, exercise, or lesson
  void goToBack({required BuildContext buildContext}) async {
    if (widget.lessonIndex != 1 && entitlementProvider.entitlement != Entitlement.pro) {
      changeScreen(buildContext, Subscription());
      return;
    }
    // Case 1: Inside exercises
    if (widget.exerciseIndex != null && widget.exerciseIndex! > 0) {
      // Go to previous exercise
      changeScreenReplacement(
        buildContext,
        BottomNavbar(
          pageIndex: widget.previousPageIndex,
          newpage: DecisionScreen(
            isReview: widget.isReview,
            lessonIndex: widget.lessonIndex,
            lessonData: lessonData,
            subLessonIndex: widget.subLessonIndex,
            exerciseIndex: widget.exerciseIndex! - 1,
            //exerciseScore is sum of exercise scores up to that exercise
            exerciseScore: (widget.exerciseScore ?? 0) - (widget.exerciseScoreTrackingList?.last ?? 0),
            exerciseScoreTrackingList: () {
              //Used to prevent adding up exercise score to exercise screen you completed before
              List<double> exerciseScoreList = widget.exerciseScoreTrackingList ?? [];
              exerciseScoreList.removeLast();
              return exerciseScoreList;
            }(),
            previousPageIndex: widget.previousPageIndex,
          ),
        ),
      );
    } else if (widget.exerciseIndex != null && widget.exerciseIndex == 0) {
      // If on first exercise, go back to last sub-lesson
      changeScreenReplacement(
        buildContext,
        BottomNavbar(
          pageIndex: widget.previousPageIndex,
          newpage: DecisionScreen(
            isReview: widget.isReview,
            lessonIndex: widget.lessonIndex,
            lessonData: lessonData,
            subLessonIndex: widget.subLessonIndex - 1,
            previousPageIndex: widget.previousPageIndex,
          ),
        ),
      );
    }
    // Case 2: Inside sub-lessons
    else if (widget.subLessonIndex > 0) {
      changeScreenReplacement(
        buildContext,
        BottomNavbar(
          pageIndex: widget.previousPageIndex,
          newpage: DecisionScreen(
            isReview: widget.isReview,
            lessonIndex: widget.lessonIndex,
            lessonData: lessonData,
            subLessonIndex: widget.subLessonIndex - 1,
            previousPageIndex: widget.previousPageIndex,
          ),
        ),
      );
    }
    // Case 3: On first sub-lesson of a lesson
    // Case 4: Already at very first lesson & sublesson
    else {
      changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0)); // or do nothing
    }
  }
}
