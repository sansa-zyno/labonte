import 'dart:convert';
//import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/models/lesson_progress.dart';
import 'package:french_app/models/review.dart';
import 'package:french_app/models/user.dart';
import 'package:french_app/services/local_storage.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final String _usersCollection = 'users';

  // Get the current authenticated user
  static User? get currentUser => _auth.currentUser;

  static DateTime _lastSyncedLessonProgress = DateTime.now();

  // set user
  static Future<void> createUser(String userId, UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set(user.toMap());
    } catch (e) {
      //print('Error setting user: $e');
      rethrow;
    }
  }

  // Update user
  static Future<void> updateUser(String userId, UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(user.toMap());
    } catch (e) {
      //print('Error updating user: $e');
      rethrow;
    }
  }

  // Update user subscription status
  static Future<void> updateUserSubscriptionStatus(
      String userId, isSubscribed) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({'isSubscribed': isSubscribed});
    } catch (e) {
      // print('Error updating User Subscription Status: $e');
      rethrow;
    }
  }

  // Get user by ID
  static Future<UserModel?> getUser(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      //print('Error getting user: $e');
      rethrow;
    }
  }

  // Get current user model
  static Future<UserModel?> getCurrentUserModel() async {
    try {
      final user = currentUser;
      if (user == null) return null;
      return getUser(user.uid);
    } catch (e) {
      //print('Error getting current user model: $e');
      rethrow;
    }
  }

  // Delete user
  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      //print('Error updating user: $e');
      rethrow;
    }
  }

  /// update user's lesson progress locally and remotely
  static Future<void> updateLessonProgress(
      {required BuildContext context,
      required String lessonIndex,
      required LessonData lessonData,
      required int currentSubLessonIndex,
      required int? currentExerciseIndex,
      required int totalLessonIndex,
      required double score,
      required DateTime lastUpdateTime}) async {
    final Map<String, Map<String, dynamic>> progress =
        await getLocalSavedLessonsProgress();
    progress[lessonIndex] = {
      'titleInFrench': lessonData.subLessons[0]['title'],
      'titleInEnglish': lessonData.subLessons[0]['titleEnglish'],
      'currentSubLessonIndex': currentSubLessonIndex,
      'currentExerciseIndex': currentExerciseIndex,
      'totalLessonIndex': totalLessonIndex,
      'score': score,
      'lastUpdateTime': lastUpdateTime.millisecondsSinceEpoch
    };
    /* await LocalStorage().setString('continueSubLessonIndex', '$currentSubLessonIndex');
    await LocalStorage().setString('continueExerciseIndex', '$currentExerciseIndex');
     if (context.mounted) {
      Provider.of<AppProvider>(context, listen: false).continueSubLessonIndex = currentSubLessonIndex;
      Provider.of<AppProvider>(context, listen: false).continueExerciseIndex = currentExerciseIndex;
    }*/
    await LocalStorage()
        .setString('savedLessonsProgress', jsonEncode(progress));
    //log('Time Difference   ' + DateTime.now().difference(_lastSyncedLessonProgress).inSeconds.toString());
    if (DateTime.now().difference(_lastSyncedLessonProgress).inSeconds > 30) {
      LessonProgress lessonProgress = LessonProgress(
        titleInFrench: lessonData.subLessons[0]['title'],
        titleInEnglish: lessonData.subLessons[0]['titleEnglish'],
        currentSubLessonIndex: currentSubLessonIndex,
        currentExerciseIndex: currentExerciseIndex,
        totalLessonIndex: totalLessonIndex,
        score: score,
        lastUpdateTime: lastUpdateTime,
      );
      await updateLessonProgressRemote(false, currentUser!.uid,
          lessonData.lessonIndex.toString(), lessonProgress);
      _lastSyncedLessonProgress = DateTime.now();
    }
  }

  // update user's lesson progress on firestore
  static Future<void> updateLessonProgressRemote(bool isOnStartLesson,
      String userId, String lessonId, LessonProgress lessonProgress) async {
    try {
      DocumentReference ref = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('lessonProgress')
          .doc(lessonId);
      if (isOnStartLesson) {
        DocumentSnapshot doc = await ref.get();
        //To prevent resetting data progress always
        if (!doc.exists) {
          //To set lesson intial lesson empty data
          await ref.set(lessonProgress.toMap());
        }
      } else {
        //To update lesson data
        await ref.set(lessonProgress.toMap());
      }
      // Update user's lastActive activity timestamp in Firestore
      await _firestore.collection(_usersCollection).doc(userId).update({
        'lastActive': FieldValue.serverTimestamp(),
      }).catchError((e) {
        // Ignore cases where the user document does not exist yet
      });
    } catch (e) {
      //print('Error updating lesson progress: $e');
      rethrow;
    }
  }

//Get local lesson progress
  static Future<Map<String, Map<String, dynamic>>>
      getLocalSavedLessonsProgress() async {
    String? savedLessonsProgress =
        await LocalStorage().getString('savedLessonsProgress');
    final Map<String, dynamic> rawData =
        savedLessonsProgress != null ? jsonDecode(savedLessonsProgress) : {};
    /*final Map<String, Map<String, num?>> progress = rawData.map((key, value) {
      if (value is Map<String, dynamic>) {
        final innerMap = value.map((k, v) => MapEntry(k, v is num ? v : null));
        return MapEntry(key, innerMap);
      } else {
        return MapEntry(key, {});
      }
    });*/
    final Map<String, Map<String, dynamic>> progress =
        rawData.map((key, value) => MapEntry(key, value));
    return progress;
  }

  // Get user's lesson progress Local + Remote
  static Stream<Map<String, LessonProgress>> getUserLessonProgress(
      String userId) async* {
    try {
      // Local data load happens only once at the start
      final Map<String, Map<String, dynamic>> localData =
          await getLocalSavedLessonsProgress();
      // Firestore snapshot stream
      final firestoreStream = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('lessonProgress')
          .snapshots();
      // Listen for Firestore updates
      await for (final snapshot in firestoreStream) {
        final Map<String, LessonProgress> progressMap = {};
        // Sort docs by ID (numerically)
        final orderedDocs = List.from(snapshot.docs);
        orderedDocs.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
        for (var doc in orderedDocs) {
          progressMap[doc.id] = LessonProgress.fromMap(doc.data());
        }
        // Merge Firestore + Local
        final merged = Map<String, LessonProgress>.from(progressMap);
        //
        localData.forEach((lessonIndex, localProgress) {
          int localLastUpdateTime = localProgress['lastUpdateTime'] ?? 0;
          // log('localTime${localLastUpdateTime}*******remoteTime>>>${merged[lessonIndex]?.lastUpdateTime.millisecondsSinceEpoch ?? 0}');
          if (!merged.containsKey(lessonIndex) ||
              localLastUpdateTime >
                  (merged[lessonIndex]?.lastUpdateTime.millisecondsSinceEpoch ??
                      0)) {
            merged[lessonIndex] = LessonProgress(
              titleInFrench: localProgress['titleInFrench'].toString(),
              titleInEnglish: localProgress['titleInEnglish'].toString(),
              currentSubLessonIndex:
                  localProgress['currentSubLessonIndex']?.toInt() ?? 0,
              currentExerciseIndex:
                  localProgress['currentExerciseIndex']?.toInt(),
              totalLessonIndex: localProgress['totalLessonIndex']?.toInt() ?? 1,
              score: localProgress['score']?.toDouble() ?? 0,
              lastUpdateTime: DateTime.fromMillisecondsSinceEpoch(
                  localProgress['lastUpdateTime']?.toInt() ?? 0),
            );
          }
        });
        yield merged;
      }
    } catch (e) {
      //print('Error getting user lesson progress: $e');
      rethrow;
    }
  }

  // Add lesson to user's review
  static Future<void> addLessonToReviews(
      String userId, String lessonId, Review review) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('reviews')
          .doc(lessonId)
          .set(review.toMap());
    } catch (e) {
      //print('Error adding to reviews: $e');
      rethrow;
    }
  }

  // Get user's reviews
  static Stream<List<Review>> getUserReviews(String userId) {
    try {
      return _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('reviews')
          .snapshots()
          .map((snapshot) {
        final orderedDocs = snapshot.docs;
        orderedDocs.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
        return orderedDocs.map((doc) => Review.fromMap(doc.data())).toList();
      });
    } catch (e) {
      //print('Error getting user reviews: $e');
      rethrow;
    }
  }

  // delete lesson from user's review
  static Future<void> removeLessonFromReviews(
      String userId, String lessonId) async {
    try {
      DocumentReference ref = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('reviews')
          .doc(lessonId);
      DocumentSnapshot doc = await ref.get();
      if (doc.exists) {
        await ref.delete();
      }
    } catch (e) {
      //print('Error removing from reviews: $e');
      rethrow;
    }
  }

//find the next unpassed lesson
  static Future<int?> findNextUnpassedLesson({
    required String userId,
    required int currentLessonIndex,
    required int totalLessons,
    required int maxScore,
    double passMark = 50.0,
  }) async {
    int nextLessonIndex = currentLessonIndex + 1;

    while (nextLessonIndex <= totalLessons) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('lessonProgress')
          .doc(nextLessonIndex.toString())
          .get();

      final double existingScore = docSnapshot.exists
          ? (docSnapshot.data()?['score'] ?? 0).toDouble()
          : 0.0;
      if (maxScore == 0) {
        maxScore =
            1; //Prevent NAN when it's no-exercise type of lesson e.g lesson 26
      }
      int percentScore = ((existingScore / maxScore) * 100).round();

      if (percentScore < passMark) {
        return nextLessonIndex; // Found a lesson below pass mark
      }

      nextLessonIndex++;
    }

    return null; // All lessons passed
  }
}
