import 'package:flutter/material.dart';
import 'const.dart';

class Detail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              constraints: BoxConstraints(
                  minWidth: double.infinity,
                  maxWidth: double.infinity,
                  minHeight: 56.0,
                  maxHeight: 56.0),
              child: Padding(
                padding: EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
                child: EnvironmentWidget(),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                constraints: BoxConstraints(
                    minWidth: double.infinity,
                    maxWidth: double.infinity,
                    minHeight: double.infinity,
                    maxHeight: double.infinity),
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
                  child: Container(
                    color: Colors.grey[50],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
                child: Container(
                  color: Colors.grey[50],
                  child: TextFormField(
                    initialValue: message,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      labelText: 'Notification',
                    ),
                    maxLines: 8,
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              constraints: BoxConstraints(
                  minWidth: double.infinity,
                  maxWidth: double.infinity,
                  minHeight: 120.0,
                  maxHeight: 120.0),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Container(
                  color: Colors.grey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('[2019 12-31 09:12] $index'),
                        );
                      },
                      itemCount: 100,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EnvironmentWidget extends StatelessWidget {
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
          Switch(
            value: true,
            onChanged: (bool changed) {},
          )
        ],
      ),
    );
  }
}
