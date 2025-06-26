import 'package:flutter/material.dart';

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
        itemCount: 20,
        itemBuilder: (context, index) =>
            Container(padding: EdgeInsets.all(5), child: Text("data $index")),
      ),
    );
  }
}
