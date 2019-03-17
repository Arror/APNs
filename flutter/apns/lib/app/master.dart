import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Master extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        APNsBar(),
        Expanded(
          flex: 1,
          child: APNsBody(),
        )
      ],
    );
  }
}

class APNsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      constraints: BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
        maxHeight: 64.0,
        minHeight: 64.0
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 12.0, right: 20.0, bottom: 8.0),
            child: Text(
              '服务器',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23.0,
                fontFamily: 'PingFang-SC',
                decoration: TextDecoration.none
              )
            ),
          )
        ],
      ),
    );
  }
}

class APNsBody extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
              itemBuilder: (BuildContext context, int index) {
                return ServerCard(
                  name: 'Arror Sever Provider',
                  editTapped: () {

                  },
                  deleteTapped: () {

                  },
                );
              },
              itemCount: 10,
            ),
          ),
          Container(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              maxWidth: double.infinity,
              minHeight: 40.0,
              maxHeight: 40.0
            ),
            color: Colors.blue,
            child: RaisedButton(
              color: Colors.blue,
              child: Text(
                '添加服务器',
                style: TextStyle(
                  fontFamily: 'PingFang-SC',
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: 400.0,
                          maxWidth: 400.0,
                          minHeight: 400.0,
                          maxHeight: 400.0
                        ),
                        color: Colors.white,
                      ),
                    );
                  }
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ServerCard extends StatelessWidget {

  ServerCard({Key key, @required this.name, this.editTapped, this.deleteTapped}) : super(key:key);

  final String name;
  final VoidCallback editTapped;
  final VoidCallback deleteTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Radio(
                  value: true,
                  groupValue: true,
                  onChanged: (bool changed) {

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