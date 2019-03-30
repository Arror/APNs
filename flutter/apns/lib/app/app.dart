import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: 'APNs Provider',
      home: Scaffold(
        appBar: AppBar(
          title: Text('APNs Provider'),
        ),
        body: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ProviderPage(),
            ),
            Expanded(
              flex: 2,
              child: Scaffold(
              ),
            )
          ],
        )
      ),
    );
  }
}

class ProviderPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              TitleValueWidget(
                title: 'Certifiate',
                value: 'SSFSDFSDFS',
              ),
              TitleValueWidget(
                title: 'Team ID',
                value: 'SSFSDFSDFS',
              ),
              TitleValueWidget(
                title: 'Key ID',
                value: 'SSFSDFSDFS',
              ),
              TitleValueWidget(
                title: 'Bundle ID',
                value: 'SSFSDFSDFS',
              )
            ],
          )
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: Icon(Icons.edit),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.only(top: 8.0, left: 24.0, right: 24.0, bottom: 12.0),
                title: Text('编辑 Provider'),
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Certificate',
                      contentPadding: EdgeInsets.only(top: 15.0, bottom: 4.0)
                    ),
                    onTap: () {
                      print('Tapped.');
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Team ID',
                      contentPadding: EdgeInsets.only(top: 15.0, bottom: 4.0)
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Key ID',
                      contentPadding: EdgeInsets.only(top: 15.0, bottom: 4.0)
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Bundle ID',
                      contentPadding: EdgeInsets.only(top: 15.0, bottom: 4.0)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: RaisedButton(
                            color: Colors.grey,
                            child: Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: RaisedButton(
                            child: Text('确定'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            }
          );
        },
      ),
    );
  }
}

class TitleValueWidget extends StatelessWidget {

  TitleValueWidget({
    Key key, 
    this.title, 
    this.value
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
        ),
        constraints: BoxConstraints(
          minWidth: double.infinity,
          maxWidth: double.infinity
        ),
        color: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                this.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white70
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                this.value,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}