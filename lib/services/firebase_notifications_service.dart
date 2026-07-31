import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize notification permissions, retrieve token, subscribe to topic and track activity
  /// We need to call this after login the user because we are saving tokens and user activity in Firestore
  static Future<void> initialize() async {
    try {
      // 1. Request notifications permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('User notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 2. Fetch the registration token
        final apnsToken = await _messaging.getAPNSToken();
        log('APNs token: $apnsToken');
        String? token = await _messaging.getToken();
        log('FCM token: $token');
        if (token != null) {
          await _saveTokenToDatabase(token);
        }

        // 3. Listen to token refreshes
        _messaging.onTokenRefresh.listen((newToken) async {
          await _saveTokenToDatabase(newToken);
        });

        await _messaging.subscribeToTopic('general_announcements');
      }

      // 4. Update the user's lastActive timestamp
      await updateLastActive();
    } catch (e) {
      log('Error initializing notifications: $e');
    }
  }

  /// Save FCM token under users/{userId}/tokens/{token}
  static Future<void> _saveTokenToDatabase(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('tokens')
            .doc(token)
            .set({
          'token': token,
          'createdAt': FieldValue.serverTimestamp(),
        });
        log('FCM token successfully registered in Firestore.');
      }
    } catch (e) {
      log('Error saving FCM token to Firestore: $e');
    }
  }

  /// Update the user's last active activity timestamp in Firestore
  static Future<void> updateLastActive() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
        log('User activity timestamp (lastActive) updated.');
      }
    } catch (e) {
      log('Error updating lastActive: $e');
    }
  }
}
