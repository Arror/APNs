import 'package:flutter/material.dart';
import 'package:apns/plugins/system_action.dart';

class App extends StatelessWidget {

  final _systemPlugin = APNsSystemPlugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APNs',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('APNs Provider'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.minimize),
              onPressed: () {
                _systemPlugin.performMiniaturize();
              },
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _systemPlugin.performClose();
              },
            )
          ],
        ),
        body: Container(),
      ),
    );
  }
}
