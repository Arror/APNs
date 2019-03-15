import 'package:flutter/material.dart';

class Split extends StatelessWidget {

  Split({Key key, @required this.left, @required this.right}) : super(key: key);

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: this.left,
        ),
        Expanded(
          flex: 2,
          child: this.right,
        )
      ],
    ); 
  }
}