import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:ybs/models/bus.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/route_data.dart';

class TrackingWidget extends StatefulWidget {
  final String currentLocation;
  final String distance;
  final List<RouteData> route;
  final List<BusStop> arrivedStops;
  final BusStop nextStop;

  const TrackingWidget({
    super.key,
    required this.currentLocation,
    required this.distance,
    required this.route,
    required this.arrivedStops,
    required this.nextStop,
  });

  @override
  State<TrackingWidget> createState() => _TrackingWidgetState();
}

class _TrackingWidgetState extends State<TrackingWidget> {
  bool showTrack = false;

  bool isTransitStop(int index, BusStop stop) {
    if (index < widget.route.length - 1 &&
        widget.route[index + 1].busStop == stop) {
      return true;
    }
    return false;
  }

  bool isShowStop(int index, BusStop stop) {
    if (index > 0 && widget.route[index - 1].busStop == stop) {
      return false;
    }
    return true;
  }

  bool isTransitWay(int index, Bus bus) {
    if (index > 0 && widget.route[index - 1].bus != bus) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 5, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Column(
                  children: widget.route
                      .map((r) => r.bus)
                      .toSet()
                      .map(
                        (bus) => Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_bus,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                bus.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.route.first.busStop.name,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(" ➠ "),
                          Expanded(
                            child: Text(
                              widget.route.last.busStop.name,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      Text(widget.distance, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showTrack = !showTrack;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/images/track.png", width: 24),
                        Text(showTrack ? "Hide" : "Track"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          showTrack
              ? SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 250,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.directions_walk, color: Colors.grey),
                                SizedBox(height: 18),
                              ],
                            ),
                          ),
                          for (int i = 0; i < widget.route.length; i++)
                            isTransitStop(i, widget.route[i].busStop)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 30,
                                          width: 4,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                widget.arrivedStops.contains(
                                                  widget.route[i].busStop,
                                                )
                                                ? Colors.green
                                                : Colors.grey,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(4),
                                              bottom: Radius.circular(4),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          spacing: 5,
                                          children: [
                                            Icon(
                                              Icons.compare_arrows,
                                              color:
                                                  widget.arrivedStops.contains(
                                                    widget.route[i].busStop,
                                                  )
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                            widget.route[i].busStop ==
                                                    widget.nextStop
                                                ? SizedBox(
                                                    height: 18,
                                                    child: AnimatedTextKit(
                                                      repeatForever: true,
                                                      animatedTexts: [
                                                        FadeAnimatedText(
                                                          widget
                                                              .route[i]
                                                              .busStop
                                                              .name,
                                                          textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : widget.arrivedStops.contains(
                                                    widget.route[i].busStop,
                                                  )
                                                ? Text(
                                                    widget
                                                        .route[i]
                                                        .busStop
                                                        .name,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                : Text(
                                                    widget
                                                        .route[i]
                                                        .busStop
                                                        .name,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : isShowStop(i, widget.route[i].busStop)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        isTransitWay(i, widget.route[i].bus)
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                    ),
                                                child: Icon(
                                                  Icons.directions_walk,
                                                  color:
                                                      widget.arrivedStops
                                                          .contains(
                                                            widget
                                                                .route[i]
                                                                .busStop,
                                                          )
                                                      ? Colors.green
                                                      : Colors.grey,
                                                ),
                                              )
                                            : Container(
                                                height: 30,
                                                width: 4,
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      widget.arrivedStops
                                                          .contains(
                                                            widget
                                                                .route[i]
                                                                .busStop,
                                                          )
                                                      ? Colors.green
                                                      : Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                        top: Radius.circular(4),
                                                        bottom: Radius.circular(
                                                          4,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                        Row(
                                          spacing: 5,
                                          children: [
                                            Icon(
                                              Icons.fiber_manual_record,
                                              color:
                                                  widget.arrivedStops.contains(
                                                    widget.route[i].busStop,
                                                  )
                                                  ? Colors.amber
                                                  : Colors.grey,
                                            ),
                                            widget.route[i].busStop ==
                                                    widget.nextStop
                                                ? SizedBox(
                                                    height: 18,
                                                    child: AnimatedTextKit(
                                                      repeatForever: true,
                                                      animatedTexts: [
                                                        FadeAnimatedText(
                                                          widget
                                                              .route[i]
                                                              .busStop
                                                              .name,
                                                          textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : widget.arrivedStops.contains(
                                                    widget.route[i].busStop,
                                                  )
                                                ? Text(
                                                    widget
                                                        .route[i]
                                                        .busStop
                                                        .name,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                : Text(
                                                    widget
                                                        .route[i]
                                                        .busStop
                                                        .name,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
