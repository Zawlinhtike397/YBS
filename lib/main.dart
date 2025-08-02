import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ybs/controllers/noti_controller.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/theme.dart';
import 'package:ybs/views/main_page.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) {
    AppData.positionStreamSubscription?.cancel();
    throw UnimplementedError();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    AppData.positionStreamSubscription = AppData.geolocatorPlatform
        .getPositionStream()
        .listen((Position? position) {
          if (position != null) {
            FlutterForegroundTask.sendDataToMain({
              "lat": position.latitude.toString(),
              "lon": position.longitude.toString(),
            });
          }
        });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotiController.initNotiService();
  FlutterForegroundTask.initCommunicationPort();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YBS',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: MainPage(),
    );
  }
}
