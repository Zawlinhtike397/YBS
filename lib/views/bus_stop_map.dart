import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';
import 'package:ybs/data/app_data.dart';

class BusStopMap extends StatelessWidget {
  const BusStopMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Bus Stop Map",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
      ),
      body: FmMap(
        mapOptions: MapOptions(
          initialCenter: LatLng(
            AppData.busStopList[0].latitude,
            AppData.busStopList[0].longitude,
          ),
          maxZoom: 15,
          minZoom: 5,
          initialZoom: 15,
        ),
        markers: [
          for (var i in AppData.testStop)
            Marker(
              point: LatLng(i.latitude, i.longitude),
              child: Icon(Icons.location_on, color: Colors.red),
            ),
        ],
      ),
    );
  }
}
