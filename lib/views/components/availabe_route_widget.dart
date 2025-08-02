import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:ybs/controllers/hex_color.dart';
import 'package:ybs/models/bus.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/route_data.dart';
import 'package:ybs/views/tracking_page.dart';

class AvailableRouteWidget extends StatelessWidget {
  final BusStop? selectedStartBusStop;
  final BusStop? selectedEndBusStop;
  final List<List<RouteData>> routeList;
  final Function(List<RouteData>) onSelectRoute;
  final GeoPoint userPosition;

  const AvailableRouteWidget({
    super.key,
    required this.selectedStartBusStop,
    required this.selectedEndBusStop,
    required this.routeList,
    required this.onSelectRoute,
    required this.userPosition,
  });

  @override
  Widget build(BuildContext context) {
    List<Set<Bus>> buses = [];
    for (var i in routeList) {
      Set<Bus> busSet = {};
      for (var j in i) {
        busSet.add(j.bus);
      }
      buses.add(busSet);
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Column(
        children: [
          Text(
            "လမ်းကြောင်းများ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    selectedStartBusStop!.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.arrow_forward),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    selectedEndBusStop!.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: routeList.length,
              itemBuilder: (context, index) =>
                  routeButton(context, routeList[index], buses[index], () {
                    onSelectRoute.call(routeList[index]);
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget routeButton(
    BuildContext context,
    List<RouteData> routeList,
    Set<Bus> buses,
    Function() onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TrackingPage(route: routeList, userPosition: userPosition),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 3),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 241, 241, 241),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                      child: buses.length == 1
                          ? Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: HexColor(buses.elementAt(0).colorCode),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.directions_bus,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    buses.elementAt(0).name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: HexColor(
                                    buses.elementAt(index).colorCode,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_bus,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      buses.elementAt(index).name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              separatorBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: Icon(
                                  Icons.directions_walk,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              itemCount: buses.length,
                            ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Distance: 12 km",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "20 min",
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "200 MMK",
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
