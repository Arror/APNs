import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  runApp(
    MaterialApp(
      title: 'APNs',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('APNs Provider'),
        ),
        body: Container(

        ),
      ),
    )
  );
}
