import 'package:flutter/material.dart';
import 'split.dart';
import 'master.dart';
import 'detail.dart';

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APNs',
      home: Split(
        left: Master(),
        right: Detail(),
      ),
    );
  }
}