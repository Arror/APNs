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
        toggleableActiveColor: Colors.lightBlue
      ),
      title: 'APNs Provider',
      home: Scaffold(
        appBar: AppBar(
          title: Text('APNs Provider')
        ),
        body: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: ProviderPage(),
            ),
            Expanded(
              flex: 3,
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
                        constraints: BoxConstraints.expand(height: double.minPositive),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Radio(
                              value: true,
                              groupValue: true,
                              onChanged: (bool isSelected) {

                              },
                            ),
                            Expanded(
                              child: Text(
                                'P8 Server',
                                overflow: TextOverflow.ellipsis,
                                softWrap: false
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  body: Padding(
                    padding: const EdgeInsets.only(left: 48.0, right: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TitleValueWidget(title: 'Team ID', value: 'ADFDSSDFSD'),
                              TitleValueWidget(title: 'Key ID', value: 'ADFDSSDFSD'),
                              TitleValueWidget(title: 'Team ID', value: 'ADFDSSDFSD'),
                              TitleValueWidget(title: 'Team ID', value: 'ADFDSSDFSD')
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  value: true
                )
              ],
              expansionCallback: (int idx, bool isExpand) {
                
              },
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          channle.invokeMethod('showProviderEditViewController')
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

  TitleValueWidget({Key key, @required this.title, @required this.value}) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(this.title),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(this.value),
          )
        ],
      ),
    );
  }
}