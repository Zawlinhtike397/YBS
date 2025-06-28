import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';
import 'package:ybs/models/bus_stop.dart';

class BusLineGenerator extends StatefulWidget {
  final LatLng currentPosition;
  const BusLineGenerator({super.key, required this.currentPosition});

  @override
  State<BusLineGenerator> createState() => _BusLineGeneratorState();
}

class _BusLineGeneratorState extends State<BusLineGenerator> {
  List<Marker> markers = [];
  List<LatLng> points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bus Line Generator")),
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            FmMap(
              mapOptions: MapOptions(
                initialCenter: widget.currentPosition,
                initialZoom: 13,
                onTap: (tapPosition, point) {
                  markers.add(
                    Marker(
                      point: point,
                      child: Icon(Icons.location_on, color: Colors.red),
                    ),
                  );
                  points.add(point);
                  setState(() {});
                },
              ),
              markers: markers,
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: ListView.builder(
                itemCount: points.length,
                itemBuilder: (context, index) => Text(points[index].toString()),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  List<BusStop> stops = [];
                  for (var i in points) {
                    stops.add(
                      BusStop(
                        id: 0,
                        name: "name",
                        latitude: i.latitude,
                        longitude: i.longitude,
                      ),
                    );
                  }
                  log(jsonEncode(stops));
                },
                child: Text("Generate"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
