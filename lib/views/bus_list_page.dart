import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ybs/controllers/helper.dart';
import 'package:ybs/controllers/hex_color.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus.dart';

class BusListPage extends StatefulWidget {
  const BusListPage({super.key});

  @override
  State<BusListPage> createState() => _BusListPageState();
}

class _BusListPageState extends State<BusListPage> {
  List<Bus> buses = [];
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  filterBus(String filterText) {
    buses = AppData.testbus
        .where(
          (bus) =>
              bus.name.contains(filterText) ||
              bus.routeName.contains(filterText),
        )
        .toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    filterBus("");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Bus List"),
        titleSpacing: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 244, 244, 244),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(40),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 5,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color.fromARGB(255, 198, 198, 198),
                ),
                suffixIcon: controller.text != ""
                    ? IconButton(
                        onPressed: () {
                          controller.text = "";
                          filterBus("");
                          focusNode.unfocus();
                        },
                        icon: Icon(Icons.close),
                      )
                    : null,
              ),
              onChanged: (value) {
                filterBus(value);
              },
              onTapOutside: (event) {
                focusNode.unfocus();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: buses.length,
              itemBuilder: (context, index) => BusListCard(
                bus: buses[index],
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => BusDetail(bus: buses[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BusDetail extends StatelessWidget {
  final Bus bus;
  const BusDetail({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("data"),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: bus.routeOne.length,
                  itemBuilder: (context, index) => Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    child: TimelineTile(
                      alignment: TimelineAlign.end,
                      isFirst: index == 0,
                      isLast: index == bus.routeOne.length - 1,
                      startChild: Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Text(
                          getBusStopName(bus.routeOne[index]),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      indicatorStyle: IndicatorStyle(
                        width: 15,
                        height: 15,
                        color: HexColor(bus.colorCode),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 50),
              Expanded(
                child: ListView.builder(
                  itemCount: bus.routeTwo.length,
                  itemBuilder: (context, index) => Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    child: TimelineTile(
                      alignment: TimelineAlign.start,
                      isFirst: index == 0,
                      isLast: index == bus.routeTwo.length - 1,
                      endChild: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(getBusStopName(bus.routeTwo[index])),
                      ),
                      indicatorStyle: IndicatorStyle(
                        width: 15,
                        height: 15,
                        color: HexColor(bus.colorCode),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BusListCard extends StatelessWidget {
  final Bus bus;
  final Function onTap;
  const BusListCard({super.key, required this.bus, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 0.5,
              blurRadius: 1,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          spacing: 10,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: HexColor(bus.colorCode),
                image: DecorationImage(
                  image: AssetImage("assets/images/bus_2.png"),
                  scale: 15,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      bus.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: double.infinity, child: Text(bus.routeName)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
