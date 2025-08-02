import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_map/free_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/views/bus_list_page.dart';
import 'package:ybs/views/notification_page.dart';
import 'package:ybs/views/route_finder.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isLoading = false;

  bool positionStreamStarted = false;
  Position? userPosition;
  String currentLocation = "Unknow";
  int selectedIndex = 0;
  List<Widget> pages = [];

  Future<Position?> getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return await AppData.geolocatorPlatform.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: "notificationTitle",
            notificationText: "notificationText",
          ),
        ),
      );
    }
    return null;
  }

  initData(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    // await loadBusStops();
    try {
      userPosition = await getPosition();
      pages = [
        RouteFinder(
          userPosition: LatLng(userPosition!.latitude, userPosition!.longitude),
        ),
        BusListPage(),
        NotificationPage(),
      ];
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initData(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        SystemNavigator.pop();
      },
      child: isLoading
          ? Scaffold(
              body: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/icon.png", width: 90),
                    SizedBox(height: 40),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            )
          : Scaffold(
              body: pages[selectedIndex],
              bottomNavigationBar: NavigationBarTheme(
                data: NavigationBarThemeData(
                  surfaceTintColor: Colors.transparent,
                  indicatorColor: Color(0xFFFFD32C),
                  backgroundColor: Color(0xFFF3EDF7),

                  iconTheme: WidgetStatePropertyAll(
                    IconThemeData(color: Colors.black),
                  ),
                ),
                child: NavigationBar(
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined, size: 28),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.directions_bus_outlined, size: 28),
                      label: "YBS Guide",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_outlined, size: 28),
                      label: "Notification",
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
    );
  }
}
