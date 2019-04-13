import 'package:flutter/material.dart';
import 'package:apns/home.dart';

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APNs',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

