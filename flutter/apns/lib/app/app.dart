import 'package:flutter/material.dart';
import 'package:apns/app/master/master.dart';
import 'package:apns/app/detail/detail.dart';
import 'package:apns/app/common/split.dart';

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
