import 'package:cloud_firestore/cloud_firestore.dart';

class LessonData {
  final int lessonIndex;
  final List<DocumentSnapshot> subLessons;
  final List<DocumentSnapshot> exercises;

  LessonData({
    required this.lessonIndex,
    required this.subLessons,
    required this.exercises,
  });
}
