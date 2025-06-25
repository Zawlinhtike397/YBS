import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';

class MapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  const MapView({super.key, required this.latitude, required this.longitude});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  FmData? _address;
  late LatLng src = LatLng(widget.latitude, widget.longitude);
  LatLng des = LatLng(0, 0);
  MapController mapController = MapController();
  List<Marker> markers = [];

  initData() {
    markers.add(
      Marker(
        point: src,
        child: Icon(Icons.location_on, size: 50, color: Colors.amber),
      ),
    );
    setState(() {
      markers;
    });
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              SizedBox(
                child: Map(controller: mapController, source: src, markers: []),
              ),
              Container(
                height: 60,
                padding: EdgeInsets.all(5),
                child: FmSearchField(
                  selectedValue: _address,
                  searchParams: const FmSearchParams(),
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
                    _address = data;
                    des = LatLng(data!.lat, data.lng);
                    markers.clear();
                    markers.add(
                      Marker(
                        point: src,
                        child: Icon(
                          Icons.location_on,
                          size: 50,
                          color: Colors.amber,
                        ),
                      ),
                    );
                    markers.add(
                      Marker(
                        point: des,
                        child: Icon(
                          Icons.location_on,
                          size: 50,
                          color: Colors.blue,
                        ),
                      ),
                    );
                    setState(() {
                      markers;
                    });
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
            ],
          ),
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
