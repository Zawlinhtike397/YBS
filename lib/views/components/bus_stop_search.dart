import "package:flutter/material.dart";
import "package:ybs/data/app_data.dart";
import "package:ybs/models/bus_stop.dart";

class BusStopSearch extends StatefulWidget {
  final Function(BusStop selectedStop) onSelect;
  const BusStopSearch({super.key, required this.onSelect});

  @override
  State<BusStopSearch> createState() => _BusStopSearchState();
}

class _BusStopSearchState extends State<BusStopSearch> {
  List<BusStop> busStopList = AppData.testStop;
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  filterStop(String filterText) {
    setState(() {
      busStopList = AppData.testStop
          .where(
            (e) =>
                e.name.contains(filterText) ||
                e.nearPlaces.contains(filterText) ||
                e.township.contains(filterText),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.2,
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "မှတ်တိုင်ရွေးချယ်ပါ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 243, 243, 243),
                  labelText: "မှတ်တိုင်အမည်၊ နေရာဖြင့် ရှာပါ",
                  labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: controller.text != ""
                      ? IconButton(
                          onPressed: () {
                            controller.text = "";
                            filterStop("");
                            focusNode.unfocus();
                          },
                          icon: Icon(Icons.cancel, color: Colors.grey),
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  filterStop(value);
                },
                onTapOutside: (event) {
                  focusNode.unfocus();
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: EdgeInsets.only(bottom: 5),
              width: double.infinity,
              child: Text(
                "မှတ်တိုင်များ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: busStopList.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("မှတ်တိုင် မတွေ့ရှိပါ။")],
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: busStopList.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          widget.onSelect.call(busStopList[index]);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 216, 238, 255),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        busStopList[index].name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        busStopList[index].nearPlaces,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.location_on),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}