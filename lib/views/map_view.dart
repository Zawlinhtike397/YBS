import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_map/free_map.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus_stop.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  FmData? _address;
  LatLng? src;
  LatLng? des;
  MapController mapController = MapController();
  List<Marker> markers = [];

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
    for (var i in AppData.busStopList) {
      markers.add(
        Marker(
          point: LatLng(i.latitude, i.longitude),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 1,
                  duration: Duration(seconds: 1),
                  content: Text(
                    i.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            child: Icon(Icons.location_on, color: Colors.red),
          ),
        ),
      );
    }
    setState(() {
      markers;
    });
  }

  @override
  void initState() {
    super.initState();
    loadBusStops();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            FmMap(
              mapController: mapController,
              mapOptions: MapOptions(
                minZoom: 5,
                maxZoom: 16,
                initialZoom: 9,
                initialCenter: LatLng(16.8388795, 95.8519088),
                onTap: (tapPosition, point) {},
              ),
              markers: markers,
              polylineOptions: const FmPolylineOptions(
                strokeWidth: 3,
                color: Colors.blue,
              ),
            ),
            Positioned(
              top: 40,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                padding: EdgeInsets.all(5),
                child: FmSearchField(
                  selectedValue: _address,
                  searchParams: const FmSearchParams(langs: ["my", "en"]),
                  resultViewOptions: FmResultViewOptions(
                    overlayDecoration: BoxDecoration(color: Colors.white),
                    noTextView: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Type to search"),
                    ),
                    loadingView: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Searching..."),
                    ),
                    separatorBuilder: (p0, p1) => SizedBox(),
                  ),
                  onSelected: (data) {
                    if (data != null) {
                      _address = data;
                      mapController.move(LatLng(data.lat, data.lng), 16);
                      markers.add(
                        Marker(
                          point: LatLng(data.lat, data.lng),
                          child: GestureDetector(
                            onLongPress: () {
                              markers.removeWhere(
                                (e) => e.point == LatLng(data.lat, data.lng),
                              );
                              setState(() {});
                            },
                            child: Icon(Icons.search, color: Colors.green),
                          ),
                        ),
                      );
                      setState(() {});
                    }
                  },
                  textFieldBuilder: (focus, controller, onChanged) {
                    return TextFormField(
                      focusNode: focus,
                      onChanged: onChanged,
                      controller: controller,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        hintText: 'Search',
                        suffixIcon:
                            controller.text.trim().isEmpty || !focus.hasFocus
                            ? null
                            : IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close),
                                onPressed: controller.clear,
                                visualDensity: VisualDensity.compact,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getAddress(LatLng point) {
    setState(() {
      des = point;
    });
  }
}

class Map extends StatefulWidget {
  final MapController controller;
  final LatLng source;
  final List<Marker> markers;
  const Map({
    super.key,
    required this.controller,
    required this.source,
    required this.markers,
  });

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  Widget build(BuildContext context) {
    return FmMap(
      mapController: widget.controller,
      mapOptions: MapOptions(
        minZoom: 0,
        maxZoom: 18,
        initialZoom: 16,
        initialCenter: widget.source,
      ),
      markers: widget.markers,
      polylineOptions: const FmPolylineOptions(
        strokeWidth: 3,
        color: Colors.blue,
      ),
    );
  }
}
