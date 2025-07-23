import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ybs/models/bus.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/message.dart';

class AppData {
  static final GeolocatorPlatform geolocatorPlatform =
      GeolocatorPlatform.instance;
  static StreamSubscription<Position>? positionStreamSubscription;

  static int currentBusIndex = -1;
  static bool isTracking = false;

  static FlutterTts flutterTts = FlutterTts();
  static List<BusStop> busStopList = [];
  static List<List<BusStop>> routeList = [];
  static List<Bus> busList = [];

  static final List<BusStop> testStop = [
    BusStop(id: 1, name: "နဝရတ်", latitude: 16.973274, longitude: 96.075806),
    BusStop(id: 2, name: "ကျော်စွာ", latitude: 16.971636, longitude: 96.07626),
    BusStop(id: 3, name: "တော်ဝင်", latitude: 16.968801, longitude: 96.077096),
    BusStop(
      id: 4,
      name: "ရွှေညာမောင်",
      latitude: 16.964019,
      longitude: 96.07857,
    ),
    BusStop(
      id: 5,
      name: "ကားကြီးဂိတ်",
      latitude: 16.961580314433366,
      longitude: 96.07787607237698,
    ),
    BusStop(
      id: 6,
      name: "ဆေးခန်း",
      latitude: 16.95848753712748,
      longitude: 96.07683872804047,
    ),
    BusStop(
      id: 7,
      name: "ထန်းခြောက်ပင်",
      latitude: 16.956968,
      longitude: 96.076414,
    ),
  ];

  static final List<Bus> testbus = [busOne, busTwo];

  static final Bus busOne = Bus(
    id: 1,
    name: "Bus One",
    routeName: "နဝရတ် ⇆ ကျော်စွာ",
    colorCode: "#DF504E",
    routeOne: [1, 2],
    routeTwo: [2, 1],
  );

  static final Bus busTwo = Bus(
    id: 2,
    name: "Bus Two",
    routeName: "ကျော်စွာ ⇆ ထန်းခြောက်ပင်",
    colorCode: "#405CAA",
    routeOne: [2, 3, 4, 5, 6, 7],
    routeTwo: [7, 6, 5, 4, 3, 2],
  );

  static List<Message> testMessages = [
    Message(
      id: 1,
      dateTime: DateTime.now(),
      title: "Some bus lines are being stopped.",
      text:
          "Some bus services have been suspended due to an emergency. Please be careful when traveling.",

      category: "General",
    ),
    Message(
      id: 2,
      dateTime: DateTime.now(),
      title: "A special program",
      text: "Special promotion for YBS card users! See details here.",
      category: "General",
    ),
    Message(
      id: 3,
      dateTime: DateTime.now(),
      title: "The stop will soon be reached",
      text: "You will arrive at your destination soon. Prepare to land.",
      category: "(Trip/Journey)",
    ),
    Message(
      id: 4,
      dateTime: DateTime.now(),
      title: "Arrived at the destination.",
      text: "You have reached your destination.",

      category: "(Trip/Journey)",
    ),
    Message(
      id: 5,
      dateTime: DateTime.now(),
      title: "The trip is over.",
      text: "Your trip has ended. Thank you for using our service.",
      category: "(Trip/Journey)",
    ),
    Message(
      id: 6,
      dateTime: DateTime.now(),
      title: "New bus lines emerge.",
      text:
          "A new bus route (6) has been introduced. Route details can be viewed in the app.",
      category: "Bus service",
    ),
    Message(
      id: 7,
      dateTime: DateTime.now(),
      title: "Route changes or closures",
      text: "Bus line (6) has temporarily changed its route.",
      category: "Bus service",
    ),
    Message(
      id: 8,
      dateTime: DateTime.now(),
      title: "System Maintenance.",
      text:
          "The YBS app will be undergoing system maintenance. The app will be temporarily unavailable during this period.",
      category: "System",
    ),
    Message(
      id: 9,
      dateTime: DateTime.now(),
      title: "New app update released",
      text:
          "A new version of the YBS app is available. Update to get new features and improved performance.",
      category: "System",
    ),
  ];
}
