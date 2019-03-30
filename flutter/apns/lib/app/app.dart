import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APNs Provider',
      home: Scaffold(
        appBar: AppBar(
          title: Text('APNs Provider'),
        ),
        body: Scaffold(),
        drawer: _buildDrawer(context),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text('Arror'),
          accountEmail: Text('hallo.maqinag@gmail.com'),
          currentAccountPicture: CircleAvatar(
            child: Text(
              'A',
              style: TextStyle(fontSize: 32.0),
            ),
          ),
        ),
        AboutListTile(
          icon: Icon(Icons.info),
          applicationName: 'APNs Provider',
          applicationVersion: 'Version 1.0',
        )
      ],
    ));
  }
}
