import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String titleInFrench;
  final String titleInEnglish;
  final String lessonId;
  final DateTime lastReviewedAt;
  final int reviewCount;

  Review({
    required this.titleInFrench,
    required this.titleInEnglish,
    required this.lessonId,
    required this.lastReviewedAt,
    required this.reviewCount,
  });

  factory Review.fromMap(Map<String, dynamic> data) {
    return Review(
      titleInFrench: data['titleInFrench'],
      titleInEnglish: data['titleInEnglish'],
      lessonId: data['lessonId'],
      lastReviewedAt: (data['lastReviewedAt'] as Timestamp).toDate(),
      reviewCount: data['reviewCount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titleInFrench': titleInFrench,
      'titleInEnglish': titleInEnglish,
      'lessonId': lessonId,
      'lastReviewedAt': Timestamp.fromDate(lastReviewedAt),
      'reviewCount': reviewCount,
    };
  }
}
