
import 'package:flutter/material.dart';
import 'package:apns/app/notifiers/environment.dart';
import 'package:provide/provide.dart';

class EnvironmentSwtich extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Text(
                'Production',
                style: TextStyle(fontSize: 15.0, color: Colors.black54),
              ),
            ),
          ),
          Provide<Environment>(
            builder: (BuildContext context, Widget child, Environment environment) {
              return Switch(
                value: environment.isProduction,
                onChanged: (bool changed) {
                  environment.changeEnvirnoment(changed);
                },
              );
            },
          )
        ],
      ),
    );
  }
}
