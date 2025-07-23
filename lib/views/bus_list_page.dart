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
        title: Text("YBS Guide"),
        titleSpacing: 10,
        centerTitle: true,
        elevation: 6.0,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        backgroundColor: const Color.fromARGB(255, 243, 242, 242),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 20),
            child: Text(
              'Find bus information by',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 244, 244, 244),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(5),
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
                hintText: "Enter the Bus number, Street, Place",
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
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
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
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      expand: true,
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 238, 238, 238),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [Icon(Icons.directions_bus_rounded), Text(bus.name)],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(bus.routeName, style: TextStyle(color: Colors.grey)),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            indicatorStyle: IndicatorStyle(
                              width: 20,
                              height: 20,
                              indicator: Image.asset(
                                "assets/images/start_bus_stop.png",
                              ),
                            ),
                            beforeLineStyle: LineStyle(
                              thickness: 3,
                              color: Colors.red,
                            ),
                            afterLineStyle: LineStyle(
                              thickness: 3,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                    Expanded(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
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
                              child: Text(
                                getBusStopName(bus.routeTwo[index]),
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            indicatorStyle: IndicatorStyle(
                              width: 20,
                              height: 20,
                              indicator: Image.asset(
                                "assets/images/start_bus_stop.png",
                              ),
                            ),
                            afterLineStyle: LineStyle(
                              thickness: 3,
                              color: Colors.blue,
                            ),
                            beforeLineStyle: LineStyle(
                              thickness: 3,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        // padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA),
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
              width: 70,
              height: 70,
              decoration: BoxDecoration(color: HexColor(bus.colorCode)),
              child: Icon(Icons.directions_bus, size: 50, color: Colors.white),
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
