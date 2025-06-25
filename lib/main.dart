import 'package:flutter/material.dart';
import 'package:ybs/theme.dart';
import 'package:ybs/views/home_page.dart';
import 'package:ybs/views/route_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YBS',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: HomePage(),
    );
  }
}
