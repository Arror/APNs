import 'package:flutter/material.dart';

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
                      padding: const EdgeInsets.only(left: 15.0, right: 8.0),
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
                    padding: const EdgeInsets.only(left: 64.0, right: 15.0, bottom: 15.0),
                    child: Container(
                      constraints: BoxConstraints.expand(height: 100.0),
                      color: Colors.red,
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
        },
      ),
    );
  }
}