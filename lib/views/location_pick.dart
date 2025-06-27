import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';

class LocationPick extends StatefulWidget {
  final LatLng currentPosition;
  const LocationPick({super.key, required this.currentPosition});

  @override
  State<LocationPick> createState() => _LocationPickState();
}

class _LocationPickState extends State<LocationPick> {
  late LatLng selectedPosition = widget.currentPosition;
  MapController mapController = MapController();
  FmData? selectedData;

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
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
                  onTap: (tapPosition, point) async {
                    setState(() {
                      selectedPosition = point;
                    });
                    mapController.move(selectedPosition, 13);
                    selectedData = await FmService().getAddress(
                      lat: point.latitude,
                      lng: point.longitude,
                    );
                    if (context.mounted) {
                      setState(() {});
                    }
                  },
                ),
                markers: [
                  Marker(
                    point: selectedPosition,
                    child: Icon(Icons.location_on, color: Colors.red),
                  ),
                ],
              ),
              Positioned(
                top: 20,
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
                          ),
                          onChanged: onChanged,
                        ),
                    onSelected: (FmData? data) {
                      if (data != null) {
                        selectedPosition = LatLng(data.lat, data.lng);
                        mapController.move(selectedPosition, 13);
                      }
                      setState(() {
                        selectedData = data;
                      });
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedData);
                  },
                  child: Text("ရွေးချယ်မည်"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
