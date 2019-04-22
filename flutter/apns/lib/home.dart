import 'package:flutter/material.dart';
import 'package:apns/plugins/system_action.dart';

class Home extends StatelessWidget {
  
  final _systemPlugin = APNsSystemPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('APNs Provider'),
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
      drawer: Drawer(
      ),
    );
  }
}
