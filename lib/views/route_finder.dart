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
import 'package:ybs/views/search_way.dart';

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

  TextEditingController startText = TextEditingController();
  TextEditingController endText = TextEditingController();
  TextEditingController searchText = TextEditingController();
  FocusNode startFocus = FocusNode();
  FocusNode endFocus = FocusNode();
  FocusNode serachFocus = FocusNode();

  LatLng? pointLocation;

  setBusStopMarker() {
    markers.clear();
    for (var i in AppData.testStop) {
      markers.add(
        Marker(
          point: LatLng(i.latitude, i.longitude),
          child: Image.asset("assets/images/bus_stop_1.png", width: 14),
        ),
      );
    }
    setState(() {});
  }

  setStartMarker() {
    markers.clear();
    for (var i in AppData.testStop) {
      markers.add(
        Marker(
          point: LatLng(i.latitude, i.longitude),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedStartBusStop = i;
                startText.text = i.name;
              });
              startFocus.unfocus();
              markers.clear();
            },
            child: Icon(Icons.location_on, color: Colors.red),
          ),
        ),
      );
    }
    setState(() {});
  }

  setEndMarkers() {
    markers.clear();
    for (var i in AppData.testStop) {
      markers.add(
        Marker(
          point: LatLng(i.latitude, i.longitude),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedEndBusStop = i;
                endText.text = i.name;
                markers.clear();
              });
              endFocus.unfocus();
            },
            child: Icon(Icons.location_on, color: Colors.blue),
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
    startText.text = "";
    endText.text = "";
    searchText.text = "";
    pointLocation = null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setBusStopMarker();
  }

  @override
  void dispose() {
    mapController.dispose();
    startText.dispose();
    endText.dispose();
    searchText.dispose();
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
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: TextFormField(
                controller: startText,
                focusNode: startFocus,
                style: TextStyle(fontSize: 13),
                keyboardType: TextInputType.none,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on, color: Colors.red),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "စမှတ်သတ်မှတ်ပါ",
                  labelStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                ),
                onTap: () {
                  selectedStartBusStop = null;
                  startText.text = "";
                  setStartMarker();
                },
              ),
            ),
          ),

          Positioned(
            top: 95,
            left: 5,
            right: 5,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: TextFormField(
                controller: endText,
                focusNode: endFocus,
                style: TextStyle(fontSize: 13),
                keyboardType: TextInputType.none,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "ဆုံးမှတ် သတ်မှတ်ပါ",
                  labelStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                ),
                onTap: () {
                  selectedEndBusStop = null;
                  endText.text = "";
                  setEndMarkers();
                },
              ),
            ),
          ),
          Positioned(
            top: 150,
            child: ElevatedButton(
              onPressed: () {
                if (selectedStartBusStop != null &&
                    selectedEndBusStop != null) {
                  List<RouteData> routeDataList = SearchRouteController()
                      .getRoute(selectedStartBusStop!, selectedEndBusStop!);

                  for (var i in routeDataList) {
                    markers.add(
                      Marker(
                        point: LatLng(i.busStop.latitude, i.busStop.longitude),
                        child: Icon(Icons.location_on, color: Colors.red),
                      ),
                    );
                  }
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
              child: Text("လမ်းကြောင်းရှာပါ"),
            ),
          ),

          Positioned(
            bottom: 10,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: TextFormField(
                        controller: searchText,
                        focusNode: serachFocus,
                        style: TextStyle(fontSize: 13),
                        keyboardType: TextInputType.none,
                        decoration: InputDecoration(
                          labelText: "တည်နေရာရှာရန်",
                          labelStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onTap: () async {
                          LocationData? locationData =
                              await LocationSearch.show(
                                context: context,
                                userAgent: UserAgent(
                                  appName: 'Location Search Example',
                                  email: 'support@myapp.com',
                                ),
                                mode: Mode.fullscreen,
                              );
                          if (locationData != null) {
                            searchText.text = locationData.address;
                            pointLocation = LatLng(
                              locationData.latitude,
                              locationData.longitude,
                            );
                          } else {
                            searchText.text = "";
                            pointLocation = null;
                          }
                          serachFocus.unfocus();
                        },
                      ),
                    ),
                  ),
                  IconButton.filled(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () {
                      if (pointLocation != null) {
                        mapController.move(pointLocation!, 13);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text("တည်နေရာထည့်ပါ"),
                          ),
                        );
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
          ),
        ],
      ),
    );
  }
}

class AvaliableRouteWidget extends StatelessWidget {
  final BusStop? selectedStartBusStop;
  final BusStop? selectedEndBusStop;
  final List<RouteData> routeList;

  const AvaliableRouteWidget({
    super.key,
    required this.selectedStartBusStop,
    required this.selectedEndBusStop,
    required this.routeList,
  });

  @override
  Widget build(BuildContext context) {
    Set<Bus> buses = {};
    for (var i in routeList) {
      buses.add(i.bus);
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
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoutePage(route: routeList),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(5),
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
                                      color: HexColor(
                                        buses.elementAt(0).colorCode,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                    separatorBuilder: (context, index) =>
                                        Padding(
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
          ),
        ],
      ),
    );
  }
}
