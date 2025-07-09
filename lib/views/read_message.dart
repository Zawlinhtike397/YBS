import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ybs/models/message.dart';

class ReadMessage extends StatelessWidget {
  final Message message;
  const ReadMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          spacing: 20,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    message.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.share,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  message.category,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  DateFormat("dd.MM.yyyy HH:MM").format(message.dateTime),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: Text(message.text, textAlign: TextAlign.justify),
            ),
          ],
        ),
      ),
    );
  }
}
