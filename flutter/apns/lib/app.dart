import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APNs',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('APNs Provider'),
        ),
        body: Container(),
      ),
    );
  }
}
