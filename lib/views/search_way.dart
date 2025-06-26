import 'package:flutter/material.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus_stop.dart';

class SearchWay extends StatefulWidget {
  const SearchWay({super.key});

  @override
  State<SearchWay> createState() => _SearchWayState();
}

class _SearchWayState extends State<SearchWay> {
  LocationData? startLocation;
  LocationData? endLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Way"),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: Colors.grey),
                    ),
                    child: Text(
                      startLocation == null
                          ? "စမှတ် သတ်မှတ်ပါ"
                          : startLocation!.address,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        color: startLocation == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    startLocation = await LocationSearch.show(
                      context: context,
                      userAgent: UserAgent(
                        appName: 'YBS',
                        email: 'support.ybs@gmail.com',
                      ),
                      mode: Mode.fullscreen,
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.add_location_alt_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: Colors.grey),
                    ),
                    child: Text(
                      endLocation == null
                          ? "ဆုံးမှတ် သတ်မှတ်ပါ"
                          : endLocation!.address,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        color: endLocation == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    endLocation = await LocationSearch.show(
                      context: context,
                      userAgent: UserAgent(
                        appName: 'YBS',
                        email: 'support.ybs@gmail.com',
                      ),
                      mode: Mode.fullscreen,
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.add_location_alt),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Text(
              "စမှတ်နှင့် အနီးဆုံး မှတ်တိုင်များ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: double.infinity,
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                BusStopCard(busStop: AppData.busStopList[10]),
                BusStopCard(busStop: AppData.busStopList[11]),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Text(
              "ဆုံးမှတ်နှင့် အနီးဆုံး မှတ်တိုင်များ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: double.infinity,
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                BusStopCard(busStop: AppData.busStopList.first),
                BusStopCard(busStop: AppData.busStopList[1]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 5,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: Text("စမှတ်တိုင်"),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: Text("ဆုံးမှတ်တိုင်"),
                  ),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.search)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  for (int i = 0; i < 5; i++)
                    SizedBox(
                      height: 40,
                      child: TimelineTile(
                        alignment: TimelineAlign.center,
                        startChild: i == 0
                            ? Text("Bus 1", textAlign: TextAlign.right)
                            : null,
                        endChild: Text(
                          AppData.busStopList[i].name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        indicatorStyle: IndicatorStyle(
                          width: 15,
                          height: 15,
                          color: Colors.blue,
                        ),
                        beforeLineStyle: LineStyle(color: Colors.blue),
                        isFirst: i == 0,
                      ),
                    ),
                  for (int i = 0; i < 5; i++)
                    SizedBox(
                      height: 40,
                      child: TimelineTile(
                        alignment: TimelineAlign.center,
                        startChild: i == 0
                            ? Text("Bus 2", textAlign: TextAlign.right)
                            : null,
                        endChild: Text(
                          AppData.busStopList[i + 5].name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        indicatorStyle: IndicatorStyle(
                          width: 15,
                          height: 15,
                          color: Colors.red,
                        ),
                        beforeLineStyle: LineStyle(color: Colors.red),
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

class BusStopCard extends StatelessWidget {
  final BusStop busStop;
  const BusStopCard({super.key, required this.busStop});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 3),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        spacing: 5,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/bus_stop_2.png", width: 16),
          Text(
            busStop.name,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
