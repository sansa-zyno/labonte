import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/models/user.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/services/local_storage.dart';

class AppProvider extends ChangeNotifier {
  UserModel? userModel;
  LessonData? continueLessonData;
  int continueSubLessonIndex = 0;
  int? continueExerciseIndex;
  bool isReview = false;

  Future<void> getCurrentUserModel() async {
    try {
      userModel = await DatabaseService.getCurrentUserModel();
      notifyListeners();
    } catch (e) {
      log(e.toString());
      userModel = null;
      notifyListeners();
    }
  }

  Future<void> getContinueLessonData() async {
    try {
      continueLessonData = null;
      isReview = await LocalStorage().getBool('isReview') ?? false;
      String? continueLessonIndex = await LocalStorage().getString('continueLessonIndex');
      String? continueSubLessonIndexString = await LocalStorage().getString('continueSubLessonIndex');
      String? continueExerciseIndexString = await LocalStorage().getString('continueExerciseIndex');
      continueSubLessonIndex = int.tryParse(continueSubLessonIndexString ?? '0') ?? 0;
      continueExerciseIndex = int.tryParse(continueExerciseIndexString ?? '');
      if (continueLessonIndex != null) {
        final firestore = FirebaseFirestore.instance;
        final lessonName = 'Lesson$continueLessonIndex';
        final subLessons = (await firestore.collection(lessonName).get()).docs;
        subLessons.removeWhere((doc) => doc.id == 'exercises');
        subLessons.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
        final exercises = (await firestore.collection(lessonName).doc('exercises').collection('exercises').get()).docs;
        exercises.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
        continueLessonData = LessonData(
          lessonIndex: int.parse(continueLessonIndex),
          subLessons: subLessons,
          exercises: exercises,
        );
      }
      notifyListeners();
    } catch (e) {
      log('Cannot get saved lesson data >>> ${e.toString()}');
    }
  }
}
