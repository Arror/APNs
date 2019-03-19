import 'package:flutter/material.dart';

class Detail extends StatefulWidget {

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {

  bool _isProduction;

  @override
  void initState() {
    _isProduction = false;
    super.initState();
  }

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
                maxHeight: 56.0
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
                child: Container(
                  color: Colors.grey[50],
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Production',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black54
                            ),
                          ),
                        ),
                      ),
                      Switch(
                        value: _isProduction,
                        onChanged: (bool changed) {
                          setState(() {
                            _isProduction = changed;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              constraints: BoxConstraints(
                minWidth: double.infinity,
                maxWidth: double.infinity,
                minHeight: 160.0,
                maxHeight: 160.0
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Container(
                  color: Colors.grey[50],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0, right: 12.0),
                  child: Container(
                    color: Colors.grey[50],
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
                maxHeight: 120.0
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Container(
                  color: Colors.grey[50],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}