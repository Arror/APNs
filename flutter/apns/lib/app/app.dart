import 'package:flutter/material.dart';
import 'split.dart';
import 'master.dart';

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      home: Split(
        left: Master(),
        right: Container(
          color: Colors.white,
        ),
      ),
    );
  }
}