import 'package:cloud_firestore/cloud_firestore.dart';

class LessonProgress {
  final String titleInFrench;
  final String titleInEnglish;
  final int currentSubLessonIndex;
  final int? currentExerciseIndex;
  final int totalLessonIndex;
  final double score;
  final DateTime lastUpdateTime;

  LessonProgress({
    required this.titleInFrench,
    required this.titleInEnglish,
    required this.currentSubLessonIndex,
    required this.currentExerciseIndex,
    required this.totalLessonIndex,
    required this.score,
    required this.lastUpdateTime,
  });

  factory LessonProgress.fromMap(Map<String, dynamic> data) {
    return LessonProgress(
      titleInFrench: data['titleInFrench'],
      titleInEnglish: data['titleInEnglish'],
      currentSubLessonIndex: data['currentSubLessonIndex'],
      currentExerciseIndex: data['currentExerciseIndex'],
      totalLessonIndex: data['totalLessonIndex'],
      score: data['score'],
      lastUpdateTime: (data['lastUpdateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titleInFrench': titleInFrench,
      'titleInEnglish': titleInEnglish,
      'currentSubLessonIndex': currentSubLessonIndex,
      'currentExerciseIndex': currentExerciseIndex,
      'totalLessonIndex': totalLessonIndex,
      'score': score,
      'lastUpdateTime': Timestamp.fromDate(lastUpdateTime),
    };
  }
}
