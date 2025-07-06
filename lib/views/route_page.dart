import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:minimize_flutter_app/minimize_flutter_app.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ybs/controllers/hex_color.dart';
import 'package:ybs/controllers/noti_controller.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/main.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/route_data.dart';

class RoutePage extends StatefulWidget {
  final List<RouteData> route;
  const RoutePage({super.key, required this.route});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  BusStop? currentStop;
  BusStop? nextStop;
  int currentIndex = 0;
  String currentLocation = "";
  bool isTracking = false;
  bool locationEnable = false;
  bool notiShown = false;

  showNoti() {
    notiShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: Duration(seconds: 1), content: Text(currentLocation)),
    );
  }

  Future<void> _requestPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  Future<void> _initService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
      ),
    );
  }

  Future<ServiceRequestResult> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'YBS',
        notificationText: 'Your location is tracking',
        notificationIcon: NotificationIcon(
          metaDataName: "@mipmap/launcher_icon",
        ),
        callback: startCallback,
      );
    }
  }

  Future<ServiceRequestResult> _stopService() {
    return FlutterForegroundTask.stopService();
  }

  void _onReceiveTaskData(Object data) {
    final obj = jsonDecode(jsonEncode(data));
    if (isTracking) {
      print("Change Location");
      checkLocation(double.parse(obj["lat"]), double.parse(obj["lon"]));
    }
  }

  liveTrack(BuildContext context) async {
    await _startService();
    setState(() {
      isTracking = true;
    });
  }

  checkLocation(double lat, double lon) {
    final distance = Geolocator.distanceBetween(
      lat,
      lon,
      widget.route[currentIndex].busStop.latitude,
      widget.route[currentIndex].busStop.longitude,
    );
    if (distance < 30 && distance > 10) {
      currentLocation = widget.route[currentIndex].busStop.name;
      if (currentIndex < widget.route.length - 1 &&
          widget.route[currentIndex].busStop.id ==
              widget.route[currentIndex + 1].busStop.id) {
        currentIndex = currentIndex + 1;
        currentLocation =
            "$currentLocation\nTransit bus stop!! Take off and transfer to ${widget.route[currentIndex].bus.name}";
      } else if (currentIndex < widget.route.length - 1 &&
          widget.route[currentIndex].bus.id !=
              widget.route[currentIndex + 1].bus.id) {
        currentLocation =
            "Take off at this bus stop!!\nWalk to ${widget.route[currentIndex + 1].busStop.name} and take ${widget.route[currentIndex + 1].bus.name}";
      }
      setState(() {});
      if (notiShown == false) {
        AppData.flutterTts.speak(currentLocation);
        showNoti();
      }
    } else if (distance < 10) {
      if (currentIndex < widget.route.length - 1) {
        currentIndex = currentIndex + 1;
      } else {
        currentLocation = "You are arrived to your destination";
        if (notiShown == false) {
          AppData.flutterTts.speak(currentLocation);
          showNoti();
        }
      }
    } else {
      notiShown = false;
      currentLocation = "Way to ${widget.route[currentIndex].busStop.name}";
      if (context.mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
      _initService();
    });
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isTracking,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        bool value = await showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "assets/images/tracking.gif",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: Text(
                    "Your location is currently tracing. Do you want to minimize the app and keep tracking or close the app and stop tracking?",
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.5),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 320,
                  height: 50,
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () async {
                      try {
                        await MinimizeFlutterApp.minimizeApp();
                      } catch (e) {
                        print('Error minimizing app: $e');
                      }
                      if (context.mounted) {
                        Navigator.pop(context, false);
                      }
                    },
                    child: Text(
                      "Keep Tracking",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 320,
                  height: 50,
                  child: MaterialButton(
                    color: Colors.red,
                    onPressed: () async {
                      Navigator.pop(context, true);
                      isTracking = false;
                      _stopService();
                      AppData.positionStreamSubscription?.cancel();
                    },
                    child: Text(
                      "Stop Tracking",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        if (value) {
          navigator.pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Route Page")),
        body: Column(
          children: [
            Text("Current Location"),
            Container(
              width: double.infinity,
              height: 60,
              margin: EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 238, 238, 238),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(currentLocation),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.route.length,
                itemBuilder: (context, index) => SizedBox(
                  height: 50,
                  child: TimelineTile(
                    axis: TimelineAxis.vertical,
                    alignment: TimelineAlign.center,
                    startChild:
                        index == 0 ||
                            widget.route[index].bus.id !=
                                widget.route[index - 1].bus.id
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              widget.route[index].bus.name,
                              textAlign: TextAlign.right,
                            ),
                          )
                        : null,
                    endChild: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        widget.route[index].busStop.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    indicatorStyle: IndicatorStyle(
                      width: 15,
                      height: 15,
                      color: HexColor(widget.route[index].bus.colorCode),
                    ),
                    beforeLineStyle: LineStyle(
                      color: HexColor(widget.route[index].bus.colorCode),
                    ),
                    isFirst: index == 0,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isTracking
              ? Image.asset(
                  "assets/images/moving_bus.gif",
                  height: 120,
                  width: 320,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                )
              : SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: MaterialButton(
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      liveTrack(context);
                    },
                    child: Text("LIVE TRACK"),
                  ),
                ),
        ),
      ),
    );
  }
}
