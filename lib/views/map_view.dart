import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';
import 'package:ybs/data/app_data.dart';
import 'dart:math' as math;

class MapView extends StatefulWidget {
  final LatLng currentPosition;
  const MapView({super.key, required this.currentPosition});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapController mapController = MapController();
  List<Marker> markers = [];

  addMarkers() {
    markers.add(
      Marker(
        point: widget.currentPosition,
        child: Icon(Icons.location_on, color: Colors.red),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    addMarkers();
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
              initialZoom: 16,
              keepAlive: true,
              onTap: (tapPosition, point) {
                print(point);
                setState(() {
                  markers.add(
                    Marker(
                      point: point,
                      child: Icon(Icons.location_on, color: Colors.amber),
                    ),
                  );
                });
              },
            ),
            markers: markers,
            polylineOptions: FmPolylineOptions(
              color: Colors.blue,
              strokeWidth: 3,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              List<LatLng> polylinepoints = await FmService().getPolyline([
                markers[0].point,
                markers[1].point,
              ]);
              print(polylinepoints.length);
            },
            child: Text("Test"),
          ),
        ],
      ),
    );
  }
}
