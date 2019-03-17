import 'package:flutter/material.dart';

class ServerCard extends StatelessWidget {

  ServerCard({
    Key key, 
    @required this.name, 
    this.isSelected = false, 
    this.editTapped, 
    this.deleteTapped
  }) : assert(name.length > 0), 
       super(key:key);

  final String name;
  final bool isSelected;
  final VoidCallback editTapped;
  final VoidCallback deleteTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 4.0, right: 4.0),
      child: Card(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Radio(
                  value: this.isSelected ? this.name : '',
                  groupValue: this.name,
                  onChanged: (String changed) {
                    print(changed);
                  },
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      this.name,
                      style: TextStyle(
                        fontFamily: 'PingFang-SC',
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.only(left: 100.0, right: 12.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      child: Text(
                        '编辑',
                        style: TextStyle(
                          fontFamily: 'PingFang-SC',
                          fontSize: 12.0,
                          color: Colors.blue
                        ),
                      ),
                      onPressed: this.editTapped,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      child: Text(
                        '删除',
                        style: TextStyle(
                          fontFamily: 'PingFang-SC',
                          fontSize: 12.0,
                          color: Colors.red
                        ),
                      ),
                      onPressed: this.deleteTapped,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}