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

  // setBusStopMarker(BuildContext context) async {
  //   if (busStopPoints.isNotEmpty) {
  //     await mapController.removeMarkers(busStopPoints);
  //     busStopPoints.clear();
  //   }

  //   for (var stop in AppData.testStop) {
  //     final point = GeoPoint(
  //       latitude: stop.latitude,
  //       longitude: stop.longitude,
  //     );

  //     busStopPoints.add(point);

  //     await mapController.addMarker(
  //       point,
  //       markerIcon: MarkerIcon(
  //         iconWidget: GestureDetector(
  //           onTap: () {
  //             showModalBottomSheet(
  //               constraints: BoxConstraints(maxHeight: 300),
  //               context: context,
  //               builder: (context) => Column(
  //                 children: [
  //                   SizedBox(height: 20),
  //                   Container(
  //                     width: double.infinity,
  //                     margin: EdgeInsets.symmetric(
  //                       horizontal: 20,
  //                       vertical: 10,
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Image.asset(
  //                           "assets/images/bus_stop_1.png",
  //                           width: 84,
  //                         ),
  //                         SizedBox(width: 10),
  //                         Text(
  //                           stop.name,
  //                           style: TextStyle(
  //                             color: Colors.blue,
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Text(
  //                       "အနီးရှိ နေရာများ",
  //                       style: TextStyle(
  //                         color: Colors.grey,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: SingleChildScrollView(
  //                       padding: EdgeInsets.all(10),
  //                       child: Text(
  //                         stop.nearPlaces,
  //                         style: TextStyle(fontSize: 12),
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 10),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: GestureDetector(
  //                           onTap: () {
  //                             selectedStartBusStop = stop;
  //                             start = stop.name;
  //                             Navigator.pop(context);
  //                             setState(() {});
  //                           },
  //                           child: Container(
  //                             padding: EdgeInsets.all(10),
  //                             alignment: Alignment.center,
  //                             decoration: BoxDecoration(
  //                               color: const Color.fromARGB(255, 235, 235, 235),
  //                               borderRadius: BorderRadius.horizontal(
  //                                 left: Radius.circular(40),
  //                               ),
  //                             ),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(Icons.location_on, color: Colors.red),
  //                                 Text("စမှတ်တိုင်"),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: GestureDetector(
  //                           onTap: () {
  //                             selectedEndBusStop = stop;
  //                             end = stop.name;
  //                             Navigator.pop(context);
  //                             setState(() {});
  //                           },
  //                           child: Container(
  //                             padding: EdgeInsets.all(10),
  //                             alignment: Alignment.center,
  //                             decoration: BoxDecoration(
  //                               color: const Color.fromARGB(255, 235, 235, 235),
  //                               borderRadius: BorderRadius.horizontal(
  //                                 right: Radius.circular(40),
  //                               ),
  //                             ),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(Icons.location_on, color: Colors.blue),
  //                                 Text("ဆုံးမှတ်တိုင်"),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 10),
  //                 ],
  //               ),
  //             ).then((_) => setState(() {}));
  //           },
  //           child: Container(
  //             padding: EdgeInsets.all(5),
  //             width: 100,
  //             height: 100,
  //             child: Image.asset("assets/images/bus_stop_1.png"),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

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
    if (selectedStartBusStop != null && selectedEndBusStop != null) {
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
                  onPressed: () async {
                    LocationData? locationData = await LocationSearch.show(
                      context: context,
                      userAgent: UserAgent(
                        appName: 'Location Search Example',
                        email: 'support@myapp.com',
                      ),
                      mode: Mode.fullscreen,
                    );
                    if (locationData != null) {
                      pointLocation = GeoPoint(
                        latitude: locationData.latitude,
                        longitude: locationData.longitude,
                      );
                      mapController.moveTo(pointLocation!, animate: true);
                    }
                  },
                  icon: Icon(Icons.pin_drop_rounded, color: Colors.red),
                ),
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

class BusStopSearch extends StatefulWidget {
  final Function(BusStop selectedStop) onSelect;
  const BusStopSearch({super.key, required this.onSelect});

  @override
  State<BusStopSearch> createState() => _BusStopSearchState();
}

class _BusStopSearchState extends State<BusStopSearch> {
  List<BusStop> busStopList = AppData.testStop;
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  filterStop(String filterText) {
    setState(() {
      busStopList = AppData.testStop
          .where(
            (e) =>
                e.name.contains(filterText) ||
                e.nearPlaces.contains(filterText) ||
                e.township.contains(filterText),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.2,
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) => Container(
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
            Text(
              "မှတ်တိုင်ရွေးချယ်ပါ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 243, 243, 243),
                  labelText: "မှတ်တိုင်အမည်၊ နေရာဖြင့် ရှာပါ",
                  labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: controller.text != ""
                      ? IconButton(
                          onPressed: () {
                            controller.text = "";
                            filterStop("");
                            focusNode.unfocus();
                          },
                          icon: Icon(Icons.cancel, color: Colors.grey),
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  filterStop(value);
                },
                onTapOutside: (event) {
                  focusNode.unfocus();
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: EdgeInsets.only(bottom: 5),
              width: double.infinity,
              child: Text(
                "မှတ်တိုင်များ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: busStopList.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("မှတ်တိုင် မတွေ့ရှိပါ။")],
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: busStopList.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          widget.onSelect.call(busStopList[index]);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 216, 238, 255),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        busStopList[index].name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        busStopList[index].nearPlaces,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.location_on),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

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
