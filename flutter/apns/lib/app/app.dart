import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
          ),
          toggleableActiveColor: Colors.lightBlue),
      title: 'APNs Provider',
      home: Scaffold(
          appBar: AppBar(title: Text('APNs Provider')),
          body: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: ProviderPage(),
              ),
              Expanded(
                flex: 2,
                child: Scaffold(),
              )
            ],
          )),
    );
  }
}

class ProviderPage extends StatelessWidget {
  final channle = MethodChannel('com.Arror.APNsFlutter.APNsPlugin');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: ExpansionPanelList.radio(
              children: <ExpansionPanelRadio>[
                ExpansionPanelRadio(
                    headerBuilder: (BuildContext context, bool isExpand) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          constraints:
                              BoxConstraints.expand(height: double.minPositive),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Radio(
                                value: true,
                                groupValue: true,
                                onChanged: (bool isSelected) {},
                              ),
                              Expanded(
                                child: Text('P8 Server',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    body: Container(
                      constraints: BoxConstraints(
                          minWidth: double.infinity,
                          maxWidth: double.infinity,
                          minHeight: 0.0,
                          maxHeight: double.infinity),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
                        child: Column(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                TitleValueWidget(
                                    title: '证书', value: 'ADFDSSDFSDAAD'),
                                TitleValueWidget(
                                    title: '组织 ID', value: 'ADFDSSDFSDAAD'),
                                TitleValueWidget(
                                    title: '钥匙 ID', value: 'ADFDSSDFSDAAD')
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  textColor: Colors.blue,
                                  child: Text(
                                    '编辑',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {

                                  },
                                ),
                                FlatButton(
                                  textColor: Colors.red,
                                  child: Text(
                                    '删除',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('删除'),
                                          content: Text('确定删除?'),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('取消'),
                                              textColor: Colors.blue,
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('确定'),
                                              textColor: Colors.red,
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      }
                                    );
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    value: true)
              ],
              expansionCallback: (int idx, bool isExpand) {},
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          channle
              .invokeMethod('showProviderEditViewController')
              .then((dynamic value) {
            print(value);
          }).catchError((dynamic error) {
            print(error);
          });
        },
      ),
    );
  }
}

class TitleValueWidget extends StatelessWidget {
  TitleValueWidget({Key key, @required this.title, @required this.value})
      : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Container(
        color: null,
        decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.all(Radius.circular(2.0))),
        constraints: BoxConstraints(
            minWidth: double.infinity,
            maxWidth: double.infinity,
            minHeight: 0.0,
            maxHeight: double.infinity),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(this.title,
                  style:
                      TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(this.value,
                    style: TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.normal)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
