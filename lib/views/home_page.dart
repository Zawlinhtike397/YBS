import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_map/free_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/views/bus_line_generator.dart';
import 'package:ybs/views/bus_list_page.dart';
import 'package:ybs/views/bus_stop_map.dart';
import 'package:ybs/views/map_view.dart';
import 'package:ybs/views/search_way.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // This fiel is used for testing purpose.
  late File routeFile;

  // Checking flag for location service is enable or not.
  bool isPermit = false;
  bool isLoading = false;

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool positionStreamStarted = false;
  Position? userPosition;
  String currentLocation = "Unknow";

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
      return await _geolocatorPlatform.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
    }
    return null;
  }

  loadBusStops() async {
    final data = await rootBundle.loadString('assets/ybs_dump.json');
    final json = jsonDecode(data);
    for (var i in json) {
      final stops = i["stop_list"];
      for (var stop in stops) {
        AppData.busStopList.add(
          BusStop(
            id: stop["line_no"],
            name: stop["stop_mm"],
            latitude: double.parse(stop["lat"]),
            longitude: double.parse(stop["lng"]),
          ),
        );
      }
    }
  }

  initData(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    loadBusStops();
    try {
      userPosition = await getPosition();
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
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "YBS",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              spacing: 10,
              children: [
                SizedBox(height: 20),
                Image.asset("assets/images/bus.png", width: 72),
                SizedBox(height: 20),
                Text(
                  '"YBS ဖြင့် သင့် လိုရာခရီးကို ရှေ့ဆက်ပါ"',
                  style: TextStyle(
                    color: Colors.blue,
                    fontFamily: "Z01-Umoe002",
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SelectionCard(
                      icon: Image.asset("assets/images/bus_route.png"),
                      title: "ကားလိုင်းများ",
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusListPage(),
                          ),
                        );
                      },
                    ),
                    SelectionCard(
                      icon: Image.asset("assets/images/bus_stop.png"),
                      title: "မှတ်တိုင်များ",
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BusStopMap()),
                        );
                      },
                    ),
                    SelectionCard(
                      icon: Image.asset("assets/images/search_route.png"),
                      title: "လမ်းကြောင်းရှာရန်",
                      onClick: () {
                        if (!isLoading) {
                          if (userPosition != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchWay(
                                  userPosition: LatLng(
                                    userPosition!.latitude,
                                    userPosition!.longitude,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text("Please allow location service"),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    SelectionCard(
                      icon: Image.asset("assets/images/route_history.png"),
                      title: "History",
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapView(
                              currentPosition: LatLng(
                                userPosition!.latitude,
                                userPosition!.longitude,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SelectionCard(
                      icon: Image.asset("assets/images/route_history.png"),
                      title: "Generate Bus Line",
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusLineGenerator(
                              currentPosition: LatLng(
                                userPosition!.latitude,
                                userPosition!.longitude,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          isLoading
              ? Positioned(
                  bottom: 40,
                  left: 10,
                  right: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.blue,
                          constraints: BoxConstraints(
                            maxHeight: 20,
                            minHeight: 20,
                            maxWidth: 20,
                            minWidth: 20,
                          ),
                        ),
                        Text("Wait! checking your location."),
                      ],
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

class SelectionCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final Function onClick;
  const SelectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick.call();
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            SizedBox(width: 72, height: 72, child: icon),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
