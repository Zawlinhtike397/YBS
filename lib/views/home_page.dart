import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/views/map_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late File routeFile;
  bool isPermit = false;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool positionStreamStarted = false;
  String currentLocation = "Unknow";

  double desLati = 21.8224255;
  double desLongi = 96.3426859;

  double distance = 0;

  double startLati = 0;
  double startLongi = 0;
  
  double liveLati = 0;
  double liveLongi = 0;

  double movement = 0;

  Future<void> listenToPosition() async {
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
      final position = await _geolocatorPlatform.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      startLati = position.latitude;
      startLongi = position.longitude;
      distance = FlutterMapMath.distanceBetween(
        desLati,
        desLongi,
        position.latitude,
        position.longitude,
        "feet",
      );
      
      if (AppData.busStopList.isEmpty) {
        AppData.busStopList.add(
          BusStop(
            id: 1,
            name: "Start",
            latitude: startLati,
            longitude: startLongi,
          ),
        );
      }
      if (_positionStreamSubscription == null) {
        final positionStream = _geolocatorPlatform.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.reduced,
          ),
        );
        _positionStreamSubscription = positionStream
            .handleError((error) {
              _positionStreamSubscription?.cancel();
              _positionStreamSubscription = null;
              setState(() {
                currentLocation = error.toString();
              });
            })
            .listen((position) async {
              setState(() {
                liveLati = position.latitude;
                liveLongi = position.longitude;
                movement = FlutterMapMath.distanceBetween(
                  startLati,
                  startLongi,
                  liveLati,
                  liveLongi,
                  "feet",
                );
                currentLocation = position.toString();
              });
            });
        positionStreamStarted = true;
      }
    }
  }

  initFile() async {
    Directory appDir = await getApplicationSupportDirectory();
    String filePath = join(appDir.path, "save_route.txt");
    routeFile = await File(filePath).create();
  }

  @override
  void initState() {
    super.initState();
    initFile();
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          children: [
            Image.asset("assets/images/bus.png", width: 100),
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SelectionCard(
                  icon: Image.asset("assets/images/bus_route.png"),
                  title: "ကားလိုင်းများ",
                  onClick: () {},
                ),
                SelectionCard(
                  icon: Image.asset("assets/images/bus_stop.png"),
                  title: "မှတ်တိုင်များ",
                  onClick: () {},
                ),
                SelectionCard(
                  icon: Image.asset("assets/images/search_route.png"),
                  title: "လမ်းကြောင်းရှာရန်",
                  onClick: () async {
                    
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapView(
                            latitude: startLati,
                            longitude: startLongi,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            Text(currentLocation),
            Text("Your movement: ${movement.toStringAsFixed(2)}"),

            LinearProgressIndicator(
              value: distance == 0 ? 0 : movement / distance,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),

            positionStreamStarted
                ? SizedBox()
                : MaterialButton(
                    onPressed: () async {
                      listenToPosition();
                    },
                    color: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    child: Text("Start Track Location"),
                  ),

            positionStreamStarted
                ? TextButton(
                    onPressed: () {
                      AppData.busStopList.add(
                        BusStop(
                          id: 1,
                          name: "name",
                          latitude: liveLati,
                          longitude: liveLongi,
                        ),
                      );
                      setState(() {});
                    },
                    child: Text("Mark"),
                  )
                : SizedBox(),
            for (var i in AppData.busStopList)
              SelectableText("[${i.latitude}, ${i.longitude}]"),
            TextButton(onPressed: () {}, child: Text("Open Map")),
          ],
        ),
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
