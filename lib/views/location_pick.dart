import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus_stop.dart';

class LocationPick extends StatefulWidget {
  final LatLng currentPosition;
  const LocationPick({super.key, required this.currentPosition});

  @override
  State<LocationPick> createState() => _LocationPickState();
}

class _LocationPickState extends State<LocationPick> {
  MapController mapController = MapController();
  List<Marker> markers = [];
  BusStop? selectedBusStop;
  FmData? selectedData;

  setMarkers() {
    for (var i in AppData.testStop) {
      markers.add(
        Marker(
          point: LatLng(i.latitude, i.longitude),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedBusStop = i;
              });
            },
            child: Icon(Icons.location_on, color: Colors.red),
          ),
        ),
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setMarkers();
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
            left: 10,
            right: 10,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: FmSearchField(
                selectedValue: selectedData,
                resultViewOptions: FmResultViewOptions(
                  overlayDecoration: BoxDecoration(color: Colors.white),
                  emptyView: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "နေရာ ရှာမတွေ့ပါ။",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  noTextView: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "ရှာဖွေလိုသည့် နေရာရိုက်ထည့်ပါ",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
                textFieldBuilder: (focusNode, controller, onChanged) =>
                    TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                      ),
                      onChanged: onChanged,
                    ),
                onSelected: (FmData? data) {
                  if (data != null) {
                    mapController.move(LatLng(data.lat, data.lng), 13);
                  }
                  setState(() {
                    selectedData = data;
                  });
                },
              ),
            ),
          ),
          Positioned(
            top: 100,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white60,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: TextFormField()),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: SizedBox(
              width: 320,
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        selectedBusStop == null ? "" : selectedBusStop!.name,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {
                      Navigator.pop(context, selectedBusStop);
                    },
                    icon: Icon(Icons.ads_click),
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
