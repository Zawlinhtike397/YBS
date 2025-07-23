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
        color: const Color(0xFF146BED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Icon(Icons.directions_bus, size: 18, color: Colors.white),
          Text(
            bus.name,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
