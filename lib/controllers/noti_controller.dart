import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ybs/main.dart';

class NotiController {
  static bool isAllowed = false;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotiService() async {
    isAllowed =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;

    if (isAllowed) {
      flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    }
  }

  static Future<void> showNotification({
    String title = "Title",
    String body = "Body Text",
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'noti',
          'Daily Notification',
          channelDescription: 'Notification for daily reminder',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          visibility: NotificationVisibility.public,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
