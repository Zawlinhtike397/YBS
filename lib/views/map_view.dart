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
  MapController mapController = MapController();
  // Load bus stop info from assets sample data.
  // We need to replace with api fatching data.
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

  check(LatLng start, LatLng end) async {
    List<LatLng> polyline = await FmService().getPolyline([start, end]);
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
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FmMap(
            mapController: mapController,
            mapOptions: MapOptions(
              initialCenter: LatLng(
                AppData.busStopList[0].latitude,
                AppData.busStopList[0].longitude,
              ),
              minZoom: 3,
              maxZoom: 16,
              initialZoom: 16,
            ),
            markers: [
              Marker(
                point: LatLng(
                  AppData.busStopList[0].latitude,
                  AppData.busStopList[0].longitude,
                ),
                child: Icon(Icons.location_history_rounded),
              ),
              Marker(
                point: LatLng(
                  AppData.busStopList[10].latitude,
                  AppData.busStopList[10].longitude,
                ),
                child: Icon(Icons.location_history_rounded),
              ),
            ],
            polylineOptions: FmPolylineOptions(
              strokeWidth: 5,
              color: Colors.blue,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              check(
                LatLng(
                  AppData.busStopList[0].latitude,
                  AppData.busStopList[0].longitude,
                ),
                LatLng(
                  AppData.busStopList[10].latitude,
                  AppData.busStopList[10].longitude,
                ),
              );
            },
            child: Text("Test"),
          ),
        ],
      ),
    );
  }
}
