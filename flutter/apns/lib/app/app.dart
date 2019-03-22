import 'package:flutter/material.dart';
import 'package:apns/bloc.dart';
import 'split.dart';
import 'master.dart';
import 'detail.dart';
import 'app_service.dart';

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BLoCProvider<AppService>(
      bloc:AppService(),
      child: MaterialApp(
        title: 'APNs',
        home: Split(
          left: Master(),
          right: Detail(),
        ),
      ),
    );
  }
}