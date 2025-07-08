import 'package:flutter/material.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:free_map/free_map.dart';
import 'package:ybs/controllers/hex_color.dart';
import 'package:ybs/controllers/search_route_controller.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/route_data.dart';
import 'package:ybs/views/route_page.dart';

class RouteFinder extends StatefulWidget {
  final LatLng currentPosition;
  const RouteFinder({super.key, required this.currentPosition});

  @override
  State<RouteFinder> createState() => _RouteFinderState();
}

class _RouteFinderState extends State<RouteFinder> {
  MapController mapController = MapController();
  List<Marker> markers = [];
  BusStop? selectedStartBusStop;
  BusStop? selectedEndBusStop;

  String start = "";
  String end = "";

  LatLng? pointLocation;

  setBusStopMarker(BuildContext context) {
    markers.clear();
    for (var i in AppData.testStop) {
      markers.add(
        Marker(
          point: LatLng(i.latitude, i.longitude),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                constraints: BoxConstraints(maxHeight: 300),
                context: context,
                builder: (context) => Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Text(
                        i.name,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          i.nearPlaces,
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        bottom: 20,
                      ),
                      child: Row(
                        spacing: 3,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                selectedStartBusStop = i;
                                start = i.name;
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    241,
                                    241,
                                    241,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 10,
                                  children: [
                                    Icon(Icons.location_on, color: Colors.red),
                                    Text("စမှတ်တိုင်"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                selectedEndBusStop = i;
                                end = i.name;
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    241,
                                    241,
                                    241,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  spacing: 10,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on, color: Colors.blue),
                                    Text("ဆုံးမှတ်တိုင်"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).then((value) {
                setState(() {});
              });
            },
            child: Image.asset("assets/images/bus_stop_1.png", width: 14),
          ),
        ),
      );
    }
    setState(() {});
  }

  clearAllData() {
    markers.clear();
    selectedStartBusStop = null;
    selectedEndBusStop = null;
    start = "";
    end = "";
    pointLocation = null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setBusStopMarker(context);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FmMap(
            mapController: mapController,
            mapOptions: MapOptions(
              initialCenter: widget.currentPosition,
              minZoom: 3,
              maxZoom: 16,
              initialZoom: 13,
              keepAlive: true,
            ),
            markers: markers,
          ),
          Positioned(
            top: 40,
            left: 5,
            right: 5,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
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
          Positioned(
            top: 100,
            left: 5,
            right: 5,
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
          Positioned(
            top: 160,
            right: 5,
            child: MaterialButton(
              shape: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              color: Colors.blue,
              onPressed: () {
                if (selectedStartBusStop != null &&
                    selectedEndBusStop != null) {
                  List<List<RouteData>> routeDataList = SearchRouteController()
                      .searchRoute(selectedStartBusStop!, selectedEndBusStop!);
                  setState(() {});
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => AvaliableRouteWidget(
                      selectedStartBusStop: selectedStartBusStop,
                      selectedEndBusStop: selectedEndBusStop,
                      routeList: routeDataList,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 1),
                      content: Text("စမှတ်၊ ဆုံးမှတ် ရွေးချယ်ပါ။"),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "လမ်းကြောင်းရှာပါ",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        width: double.infinity,
                        child: Column(children: [Text("Search")]),
                      ),
                    );
                  },
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
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
                      pointLocation = LatLng(
                        locationData.latitude,
                        locationData.longitude,
                      );
                      mapController.move(pointLocation!, 13);
                    }
                  },
                  icon: Icon(Icons.pin_drop_rounded, color: Colors.red),
                ),
                IconButton.filled(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: () {
                    mapController.move(
                      LatLng(
                        widget.currentPosition.latitude,
                        widget.currentPosition.longitude,
                      ),
                      13,
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

class AvaliableRouteWidget extends StatelessWidget {
  final BusStop? selectedStartBusStop;
  final BusStop? selectedEndBusStop;
  final List<List<RouteData>> routeList;

  const AvaliableRouteWidget({
    super.key,
    required this.selectedStartBusStop,
    required this.selectedEndBusStop,
    required this.routeList,
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
                  routeButton(context, routeList[index], buses[index]),
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
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoutePage(route: routeList)),
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
