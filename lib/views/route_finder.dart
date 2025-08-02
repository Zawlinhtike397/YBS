import 'package:flutter/material.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:ybs/controllers/hex_color.dart';
import 'package:ybs/controllers/search_route_controller.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/route_data.dart';
import 'package:latlong2/latlong.dart';
import 'package:ybs/views/components/availabe_route_widget.dart';
import 'package:ybs/views/components/bus_stop_search.dart';
import 'package:ybs/views/tracking_page.dart';

class RouteFinder extends StatefulWidget {
  final LatLng userPosition;
  const RouteFinder({super.key, required this.userPosition});

  @override
  State<RouteFinder> createState() => _RouteFinderState();
}

class _RouteFinderState extends State<RouteFinder> {
  late MapController mapController = MapController(
    initPosition: GeoPoint(
      latitude: widget.userPosition.latitude,
      longitude: widget.userPosition.longitude,
    ),
  );
  OSMOption option = OSMOption(
    zoomOption: ZoomOption(initZoom: 13),
    showZoomController: true,
  );
  List<GeoPoint> markers = [];
  GeoPoint? pointLocation;
  BusStop? selectedStartBusStop;
  BusStop? selectedEndBusStop;
  List<LatLng> routePoints = [];
  List<GeoPoint> busStopPoints = [];

  String start = "";
  String end = "";

  setBusStopMarker(BuildContext context) async {
    if (busStopPoints.isNotEmpty) {
      await mapController.removeMarkers(busStopPoints);
      busStopPoints.clear();
    }

    for (var stop in AppData.testStop) {
      final point = GeoPoint(
        latitude: stop.latitude,
        longitude: stop.longitude,
      );

      busStopPoints.add(point);

      await mapController.addMarker(
        point,
        markerIcon: MarkerIcon(
          iconWidget: Container(
            padding: EdgeInsets.all(5),
            width: 100,
            height: 100,
            child: Image.asset("assets/images/bus_stop_1.png"),
          ),
        ),
      );
    }
  }

  clearAllData() {
    selectedStartBusStop = null;
    selectedEndBusStop = null;
    start = "";
    end = "";
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _showAvailableRoutes() {
    if (selectedStartBusStop != null &&
        selectedEndBusStop != null &&
        selectedStartBusStop != selectedEndBusStop) {
      List<List<RouteData>> routeDataList = SearchRouteController().searchRoute(
        selectedStartBusStop!,
        selectedEndBusStop!,
      );
      showModalBottomSheet(
        context: context,
        builder: (context) => AvailableRouteWidget(
          selectedStartBusStop: selectedStartBusStop,
          selectedEndBusStop: selectedEndBusStop,
          routeList: routeDataList,
          userPosition: GeoPoint(
            latitude: widget.userPosition.latitude,
            longitude: widget.userPosition.longitude,
          ),
          onSelectRoute: (selectedRoute) async {
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          OSMFlutter(
            controller: mapController,
            osmOption: option,
            onMapIsReady: (isReady) async {
              if (isReady) {
                await setBusStopMarker(context);
              }
            },
            onGeoPointClicked: (point) {
              final stop = AppData.testStop.firstWhere(
                (s) =>
                    s.latitude == point.latitude &&
                    s.longitude == point.longitude,
              );

              showModalBottomSheet(
                constraints: BoxConstraints(maxHeight: 300),
                context: context,
                builder: (context) => PointerInterceptor(
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/bus_stop_1.png",
                                width: 50,
                              ),
                              SizedBox(width: 10),
                              Text(
                                stop.name,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "အနီးရှိ နေရာများ",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              stop.nearPlaces,
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    selectedStartBusStop = stop;
                                    start = stop.name;
                                    Navigator.pop(context);
                                    _showAvailableRoutes();
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        235,
                                        235,
                                        235,
                                      ),
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(40),
                                        right: Radius.circular(40),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                        ),
                                        Text("စမှတ်တိုင်"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    selectedEndBusStop = stop;
                                    end = stop.name;
                                    Navigator.pop(context);
                                    _showAvailableRoutes();
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        235,
                                        235,
                                        235,
                                      ),
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(40),
                                        right: Radius.circular(40),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.blue,
                                        ),
                                        Text("ဆုံးမှတ်တိုင်"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          Positioned(
            top: 40,
            left: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => BusStopSearch(
                    onSelect: (selectedStop) {
                      selectedStartBusStop = selectedStop;
                      setState(() {
                        start = selectedStop.name;
                      });
                      Navigator.pop(context);
                      _showAvailableRoutes();
                    },
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.location_on, color: Colors.red),
                    Text(
                      start == "" ? "စမှတ်တိုင်" : start,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => BusStopSearch(
                    onSelect: (selectedStop) {
                      selectedEndBusStop = selectedStop;
                      setState(() {
                        end = selectedStop.name;
                      });
                      Navigator.pop(context);
                      _showAvailableRoutes();
                    },
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    Text(
                      end == "" ? "ဆုံးမှတ်တိုင်" : end,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 10,
            right: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filled(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: () {
                    GeoPoint currentGeoPoint = GeoPoint(
                      latitude: widget.userPosition.latitude,
                      longitude: widget.userPosition.longitude,
                    );
                    mapController.moveTo(currentGeoPoint, animate: true);
                    mapController.zoomIn();
                    mapController.removeMarker(currentGeoPoint);
                    mapController.addMarker(
                      currentGeoPoint,
                      markerIcon: MarkerIcon(
                        icon: Icon(
                          Icons.gps_fixed_sharp,
                          color: Colors.blue,
                          size: 80.0,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.gps_fixed, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}