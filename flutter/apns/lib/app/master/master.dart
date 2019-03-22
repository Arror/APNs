import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import 'package:apns/app/models/certificate.dart';

class Master extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final certificate = Provide.value<Certificate>(context);

    return Scaffold(
        appBar: AppBar(title: Text('APNs Provider')),
        body: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Team ID',
                      hintText: '请输入 Team ID',
                      contentPadding: EdgeInsets.only(bottom: 2.0)
                    ),
                    onChanged: (String text) {
                      certificate.teamID = text;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Key ID',
                      hintText: '请输入 Key ID',
                      contentPadding: EdgeInsets.only(bottom: 2.0)
                    ),
                    onChanged: (String text) {
                      certificate.keyID = text;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Bundle ID',
                      hintText: '请输入 Bundle ID',
                      contentPadding: EdgeInsets.only(bottom: 2.0)
                    ),
                    onChanged: (String text) {
                      certificate.bundleID = text;
                    },
                  ),
                )
              ],
            )
          ],
        )
    );
  }
}
