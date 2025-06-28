import 'package:flutter/material.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus.dart';

class BusListPage extends StatelessWidget {
  const BusListPage({super.key});

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
      body: ListView.builder(
        itemCount: AppData.testbus.length,
        itemBuilder: (context, index) =>
            BusListCard(bus: AppData.testbus[index]),
      ),
    );
  }
}

class BusListCard extends StatelessWidget {
  final Bus bus;
  const BusListCard({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(color: Colors.black12, spreadRadius: 0.5, blurRadius: 1),
        ],
      ),
      child: Row(
        spacing: 10,
        children: [
          Image.asset("assets/images/bus.png", width: 32),
          Expanded(
            child: Column(
              children: [
                SizedBox(width: double.infinity, child: Text(bus.name)),
                SizedBox(width: double.infinity, child: Text(bus.routeName)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
