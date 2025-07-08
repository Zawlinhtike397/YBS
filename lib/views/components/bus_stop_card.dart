import 'package:flutter/material.dart';
import 'package:ybs/models/bus_stop.dart';

class BusStopCard extends StatelessWidget {
  final BusStop busStop;
  final Function onTap;
  const BusStopCard({super.key, required this.busStop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
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
      ),
    );
  }
}
