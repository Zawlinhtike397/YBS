import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:minimize_flutter_app/minimize_flutter_app.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/main.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/route_data.dart';
import 'package:ybs/views/components/tracking_widget.dart';
import 'package:ybs/views/thank_you_page.dart';

class TrackingPage extends StatefulWidget {
  final List<RouteData> route;
  final GeoPoint userPosition;
  const TrackingPage({
    super.key,
    required this.route,
    required this.userPosition,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage>
    with WidgetsBindingObserver {
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  late BusStop nextStop;
  int currentIndex = 0;
  String currentLocation = "You are not currently tracking!!";

  bool isTracking = false;
  bool locationEnable = false;
  bool notiShown = false;
  bool isMapReady = false;

  String stageImage = "assets/images/navigation.gif";
  late MapController controller;
  OSMOption option = OSMOption(zoomOption: ZoomOption(initZoom: 14));
  late GeoPoint userLocation = widget.userPosition;
  String distance = "";
  List<BusStop> arrivedStops = [];

  bool _shouldShowAlertDialog = false;
  bool _shouldNavigateThankYou = false;
  bool hasNavigatedToThankYou = false;

  GeoPoint? _lastUserLocationMarker;

  showNoti() {
    notiShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: Duration(seconds: 1), content: Text(currentLocation)),
    );
  }

  Future<void> _requestPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
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

  Future<void> _onReceiveTaskData(Object data) async {
    final obj = jsonDecode(jsonEncode(data));
    final location = GeoPoint(
      latitude: double.parse(obj["lat"]),
      longitude: double.parse(obj["lon"]),
    );

    if (isMapReady) {
      if (_lastUserLocationMarker != null) {
        await controller.removeMarker(_lastUserLocationMarker!);
      }

      _lastUserLocationMarker = location;

      await controller.addMarker(
        location,
        markerIcon: MarkerIcon(
          icon: Icon(Icons.location_history, size: 50, color: Colors.blue),
        ),
      );
      await controller.moveTo(location, animate: false);
    }
    if (isTracking) {
      checkLocation(double.parse(obj["lat"]), double.parse(obj["lon"]));
    }
  }

  liveTrack(BuildContext context) async {
    nextStop = widget.route.first.busStop;
    await _startService();
    setState(() {
      isTracking = true;
    });
  }

  void _showNearDestinationAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.directions_bus_outlined,
            color: Colors.grey,
            size: 29.0,
          ),
          title: Text(
            'The YBS ${widget.route.last.bus.name} will arrived your destination (${widget.route.last.busStop.name}) after 2 bus-stops. Preparing to get off.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Don't forgot to bring your belonging before you getting off. Thank you for your ride. Have a great day!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFF49454F),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.amber,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void checkLocation(double lat, double lon) {
    final distance = Geolocator.distanceBetween(
      lat,
      lon,
      widget.route[currentIndex].busStop.latitude,
      widget.route[currentIndex].busStop.longitude,
    );
    if (distance < 30 && distance > 10) {
      currentLocation = widget.route[currentIndex].busStop.name;
      stageImage = "assets/images/bus_stop.gif";
      if (currentIndex < widget.route.length - 1 &&
          widget.route[currentIndex].busStop.id ==
              widget.route[currentIndex + 1].busStop.id) {
        currentIndex = currentIndex + 1;
        currentLocation =
            "$currentLocation\nTransit bus stop!! Take off and transfer to ${widget.route[currentIndex].bus.name}";
        stageImage = "assets/images/bus_stop.gif";
      } else if (currentIndex < widget.route.length - 1 &&
          widget.route[currentIndex].bus.id !=
              widget.route[currentIndex + 1].bus.id) {
        currentLocation =
            "Take off at this bus stop!!\nWalk to ${widget.route[currentIndex + 1].busStop.name} and take ${widget.route[currentIndex + 1].bus.name}";
      }
      if (context.mounted) {
        setState(() {});
      }
      if (notiShown == false) {
        AppData.flutterTts.speak(currentLocation);
        showNoti();
      }
    } else if (distance < 10) {
      if (currentIndex == widget.route.length - 3) {
        if (_appLifecycleState == AppLifecycleState.resumed &&
            context.mounted) {
          _showNearDestinationAlert();
        } else {
          _shouldShowAlertDialog = true;
        }
      }

      arrivedStops.add(widget.route[currentIndex].busStop);
      if (currentIndex < widget.route.length - 1) {
        currentIndex = currentIndex + 1;
        nextStop = widget.route[currentIndex].busStop;
      } else {
        currentLocation = "You have arrived to your destination";
        if (!hasNavigatedToThankYou) {
          hasNavigatedToThankYou = true;
          if (_appLifecycleState == AppLifecycleState.resumed &&
              context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ThankYouPage()),
            );
          } else {
            _shouldNavigateThankYou = true;
          }
        }

        stageImage = "assets/images/bus_stop.png";
        if (notiShown == false) {
          AppData.flutterTts.speak(currentLocation);
          _stopService();
          AppData.positionStreamSubscription?.cancel();
          showNoti();
        }
      }
      if (context.mounted) {
        setState(() {});
      }
    } else {
      notiShown = false;
      if (currentIndex == 0) {
        stageImage = "assets/images/walking.gif";
      } else {
        stageImage = "assets/images/way_to.gif";
      }
      currentLocation = "Way to ${widget.route[currentIndex].busStop.name}";
      if (context.mounted) {
        setState(() {});
      }
    }
  }

  Future<void> setRoad() async {
    List<GeoPoint> markers = [];
    for (var i in widget.route) {
      markers.add(
        GeoPoint(latitude: i.busStop.latitude, longitude: i.busStop.longitude),
      );
    }
    for (var i in markers) {
      await controller.addMarker(i);
    }

    await controller.drawRoad(
      markers.first,
      markers.last,
      intersectPoint: markers,
      roadOption: RoadOption(roadColor: Colors.green, zoomInto: false),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = MapController(initPosition: userLocation);
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
      _initService();
    });
    distance =
        "${(Geolocator.distanceBetween(widget.route.first.busStop.latitude, widget.route.first.busStop.longitude, widget.route.last.busStop.latitude, widget.route.last.busStop.longitude) / 1000).toStringAsFixed(2)} Km";
    liveTrack(context);
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;

    if (state == AppLifecycleState.resumed) {
      if (_shouldShowAlertDialog) {
        _shouldShowAlertDialog = false;
        _showNearDestinationAlert();
      }

      if (_shouldNavigateThankYou && !hasNavigatedToThankYou) {
        hasNavigatedToThankYou = true;
        _shouldNavigateThankYou = false;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ThankYouPage()),
        );
      }
    }
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
        bool value = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            content: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: 320,
                height: 50,
                child: MaterialButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
        );
        if (value) {
          navigator.pop(result);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            OSMFlutter(
              controller: controller,
              osmOption: option,
              mapIsLoading: Container(
                alignment: Alignment.center,
                child: Image.asset("assets/images/navigation.gif", width: 120),
              ),
              onMapIsReady: (isReady) async {
                if (isReady) {
                  isMapReady = isReady;
                  await setRoad();
                }
              },
            ),
            Positioned(
              bottom: 0,
              child: TrackingWidget(
                currentLocation: currentLocation,
                distance: distance,
                route: widget.route,
                arrivedStops: arrivedStops,
                nextStop: nextStop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
