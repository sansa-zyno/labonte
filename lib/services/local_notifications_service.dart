import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings("@mipmap/launcher_icon");

    final InitializationSettings initializationSettings =
        InitializationSettings(iOS: iosSettings, android: androidSettings);

    await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null) {
            log(response.payload!);
          }
        });
  }

  static Future<void> createnotificationchannel() async {
    // Define the notification channel
    const AndroidNotificationChannel androidChannel =
        AndroidNotificationChannel(
      'labonte', // Replace with your desired channel ID
      'LaBonté channel',
      description: "This is LaBonté notification channel",
      importance: Importance.high,
    );
    // Create the channel
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails("labonte", "LaBonté channel",
              channelDescription: "This is LaBonté notification channel",
              importance: Importance.high,
              priority: Priority.high));

      PermissionStatus permission = await Permission.notification.status;
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.permanentlyDenied) {
        PermissionStatus status = await Permission.notification.request();
        if (status == PermissionStatus.granted) {
          await _notificationsPlugin.show(
              id: id,
              title: message.notification!.title,
              body: message.notification!.body,
              notificationDetails: notificationDetails);
        }
      } else {
        await _notificationsPlugin.show(
            id: id,
            title: message.notification!.title,
            body: message.notification!.body,
            notificationDetails: notificationDetails);
      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
