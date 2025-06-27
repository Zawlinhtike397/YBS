import 'package:flutter/material.dart';
import 'package:free_map/fm_models.dart';
import 'package:free_map/fm_service.dart';
import 'package:geodesy/geodesy.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/bus_stop_distance.dart';
import 'package:ybs/views/location_pick.dart';

class SearchWay extends StatefulWidget {
  final LatLng userPosition;
  const SearchWay({super.key, required this.userPosition});

  @override
  State<SearchWay> createState() => _SearchWayState();
}

class _SearchWayState extends State<SearchWay> {
  FmData? startLocation;
  FmData? endLocation;

  List<BusStop> startPointNearBusStopList = [];
  List<BusStop> endPointNearBusStopList = [];
  List<BusStopDistance> busStopDistanceList = [];

  List<Bus> startPointArrivalBusList = [];
  List<Bus> endPointArrivalBusList = [];

  BusStop? start;
  BusStop? end;

  List<BusStop> avaliableRoute = [];

  void findNearestBusStop({required LatLng position, required bool isStart}) {
    if (isStart) {
      startPointNearBusStopList.clear();
    } else {
      endPointNearBusStopList.clear();
    }
    busStopDistanceList.clear();
    for (var i in AppData.testStop) {
      final busStopLocation = LatLng(i.latitude, i.longitude);
      final distance = Geodesy().distanceBetweenTwoGeoPoints(
        position,
        busStopLocation,
      );
      busStopDistanceList.add(
        BusStopDistance(distance: distance as double, busStop: i),
      );
    }
    busStopDistanceList.sort((a, b) => a.distance.compareTo(b.distance));
    if (isStart) {
      startPointNearBusStopList.add(busStopDistanceList.first.busStop);
    } else {
      endPointNearBusStopList.add(busStopDistanceList.first.busStop);
    }
    setState(() {});
  }

  List<BusStop> getSameBusRoute(Bus bus, BusStop start, BusStop end) {
    List<BusStop> route = [];
    bool startStopFound = false;
    bool endStopFound = false;
    bool isRouteOne = false;
    for (var id in bus.routeOne) {
      startStopFound = id == start.id;
      endStopFound = id == end.id;
      if (startStopFound) {
        isRouteOne = true;
        break;
      } else if (endStopFound) {
        isRouteOne = false;
        break;
      }
    }
    if (isRouteOne) {
      final startIndex = bus.routeOne.indexOf(start.id);
      final endIndex = bus.routeOne.indexOf(end.id);
      for (int i = startIndex; i <= endIndex; i++) {
        route.add(
          AppData.testStop.firstWhere((stop) => stop.id == bus.routeOne[i]),
        );
      }
      return route;
    } else {
      final startIndex = bus.routeTwo.indexOf(start.id);
      final endIndex = bus.routeTwo.indexOf(end.id);
      for (int i = startIndex; i <= endIndex; i++) {
        route.add(
          AppData.testStop.firstWhere((stop) => stop.id == bus.routeTwo[i]),
        );
      }
      return route;
    }
  }

  List<BusStop> searchRoute(BusStop startStop, BusStop endStop) {
    avaliableRoute.clear();
    startPointArrivalBusList.clear();
    endPointArrivalBusList.clear();

    for (var bus in AppData.testbus) {
      if (bus.routeOne.contains(startStop.id) &&
          bus.routeOne.contains(endStop.id)) {
        return getSameBusRoute(bus, startStop, endStop);
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Way"),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: Colors.grey),
                    ),
                    child: Text(
                      startLocation == null
                          ? "စမှတ် သတ်မှတ်ပါ"
                          : startLocation!.address,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        color: startLocation == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LocationPick(currentPosition: widget.userPosition),
                      ),
                    ).then((value) {
                      setState(() {
                        startLocation = value;
                      });
                      if (startLocation != null) {
                        findNearestBusStop(
                          position: LatLng(
                            startLocation!.lat,
                            startLocation!.lng,
                          ),
                          isStart: true,
                        );
                      }
                    });
                  },
                  icon: Icon(Icons.map),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: Colors.grey),
                    ),
                    child: Text(
                      endLocation == null
                          ? "ဆုံးမှတ် သတ်မှတ်ပါ"
                          : endLocation!.address,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        color: endLocation == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LocationPick(currentPosition: widget.userPosition),
                      ),
                    ).then((value) {
                      setState(() {
                        endLocation = value;
                      });
                      if (endLocation != null) {
                        findNearestBusStop(
                          position: LatLng(endLocation!.lat, endLocation!.lng),
                          isStart: false,
                        );
                      }
                    });
                  },
                  icon: Icon(Icons.map),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Text(
              "စမှတ်နှင့် အနီးဆုံး မှတ်တိုင်များ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: double.infinity,
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: startPointNearBusStopList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "အနီးဆုံးမှတ်တိုင် မရှိပါ။",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(5),
                    itemCount: startPointNearBusStopList.length,
                    itemBuilder: (context, index) => BusStopCard(
                      busStop: startPointNearBusStopList[index],
                      onTap: () {
                        setState(() {
                          start = startPointNearBusStopList[index];
                        });
                      },
                    ),
                  ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Text(
              "ဆုံးမှတ်နှင့် အနီးဆုံး မှတ်တိုင်များ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: double.infinity,
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: endPointNearBusStopList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "အနီးဆုံးမှတ်တိုင် မရှိပါ။",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(5),
                    itemCount: endPointNearBusStopList.length,
                    itemBuilder: (context, index) => BusStopCard(
                      busStop: endPointNearBusStopList[index],
                      onTap: () {
                        setState(() {
                          end = endPointNearBusStopList[index];
                        });
                      },
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 5,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: start == null
                        ? Text("စမှတ်တိုင်")
                        : Text(start!.name),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: end == null
                        ? Text("ဆုံးမှတ်တိုင်")
                        : Text(end!.name),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (start != null && end != null) {
                      avaliableRoute = searchRoute(start!, end!);
                      setState(() {});
                    }
                  },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: avaliableRoute.isEmpty
                ? Center(child: Text("လမ်းကြောင်း မရှိပါ။"))
                : ListView.builder(
                    itemCount: avaliableRoute.length,
                    itemBuilder: (context, index) => SizedBox(
                      height: 40,
                      child: TimelineTile(
                        alignment: TimelineAlign.manual,
                        lineXY: 0.25,
                        startChild: index == 0
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text("TODO", textAlign: TextAlign.right),
                              )
                            : null,
                        endChild: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            avaliableRoute[index].name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        indicatorStyle: IndicatorStyle(
                          width: 15,
                          height: 15,
                          color: Colors.blue,
                        ),
                        beforeLineStyle: LineStyle(color: Colors.blue),
                        isFirst: index == 0,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class BusStopCard extends StatelessWidget {
  final BusStop busStop;
  final Function onTap;
  const BusStopCard({super.key, required this.busStop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        margin: EdgeInsets.only(right: 3),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/bus_stop_2.png", width: 16),
            Text(
              busStop.name,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
