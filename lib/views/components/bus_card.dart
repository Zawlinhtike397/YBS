import 'package:flutter/material.dart';
import 'package:ybs/models/bus.dart';

class BusCard extends StatelessWidget {
  final Bus bus;
  const BusCard({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 241, 241),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [Icon(Icons.directions_bus, size: 18), Text(bus.name)],
      ),
    );
  }
}
