import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ybs/controllers/hex_color.dart';
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
  late StreamSubscription<Position> _positionStreamSubscription;
  bool isTracking = false;
  bool locationEnable = false;
  bool notiShown = false;

  showNoti() {
    notiShown = true;
    // TODO: to show notification currentLocation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: Duration(seconds: 1), content: Text(currentLocation)),
    );
  }

  liveTrack() {
    setState(() {
      isTracking = true;
    });
    _positionStreamSubscription = Geolocator.getPositionStream().listen((
      Position? position,
    ) {
      if (position != null) {
        final distance = Geodesy().distanceBetweenTwoGeoPoints(
          LatLng(position.latitude, position.longitude),
          LatLng(
            widget.route[currentIndex].busStop.latitude,
            widget.route[currentIndex].busStop.longitude,
          ),
        );
        if (distance < 30) {
          currentLocation = widget.route[currentIndex].busStop.name;
          setState(() {});
          if (notiShown == false) {
            showNoti();
          }
        } else if (distance < 10) {
          if (currentIndex < widget.route.length - 1) {
            currentIndex = currentIndex + 1;
          } else {
            currentLocation = "You are arrived to your destination";
            if (notiShown == false) {
              showNoti();
            }
          }
        } else {
          notiShown = false;
          currentLocation = "Way to ${widget.route[currentIndex].busStop.name}";
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ? Container(
                width: double.infinity,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Icon(Icons.gps_fixed),
                    Text("Your Location is tracking."),
                  ],
                ),
              )
            : MaterialButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  liveTrack();
                },
                child: Text("LIVE TRACK"),
              ),
      ),
    );
  }
}
