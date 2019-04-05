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
                    return ProviderNameWidget(name: 'P8 Provider');
                  },
                  body: ProviderDetailWidget(),
                  value: true)
            ],
            expansionCallback: (int idx, bool isExpand) {},
          ),
        ),
      ),
    ));
  }
}

class ProviderDetailWidget extends StatelessWidget {

  final _plugin = APNsPlugin();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          minWidth: double.infinity,
          maxWidth: double.infinity,
          minHeight: 0.0,
          maxHeight: double.infinity),
      child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 12.0),
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  TitleValueWidget(
                    title: '证书',
                    value: 'ADFDSSDFSDAAD',
                    onTap: () {
                      _plugin.showLoadCertificateDialog().then((value) {
                        print(value);
                      }).catchError((_) {});
                    },
                  ),
                  TitleValueWidget(
                    title: '组织 ID',
                    value: 'ADFDSSDFSDAAD',
                    onTap: () {
                      _plugin.showInputDialog('输入组织 ID', '').then((value) {
                        print(value);
                      }).catchError((_) {});
                    },
                  ),
                  TitleValueWidget(
                    title: '钥匙 ID',
                    value: 'ADFDSSDFSDAAD',
                    onTap: () {
                      _plugin.showInputDialog('输入钥匙 ID', '').then((value) {
                        print(value);
                      }).catchError((_) {});
                    },
                  )
                ],
              )
            ],
          )),
    );
  }
}

class ProviderNameWidget extends StatelessWidget {
  ProviderNameWidget({Key key, @required this.name}) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 8.0),
      child: Container(
        constraints: BoxConstraints.expand(height: double.minPositive),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                  this.name,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false),
            )
          ],
        ),
      ),
    );
  }
}

class TitleValueWidget extends StatelessWidget {
  TitleValueWidget(
      {Key key,
      @required this.title,
      @required this.value,
      @required this.onTap})
      : super(key: key);

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: InkWell(
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
        onTap: this.onTap,
      ),
    );
  }
}

class APNsPlugin {

  final _channel = MethodChannel('com.Arror.APNsFlutter.APNsPlugin');

  Future<String> showInputDialog<T>(String title, String value) async {
    var dict = {
      'title': title,
      'value': value
    };
    return _channel.invokeMethod('showInputDialog', [dict]).then((value) {
      return Future.value(value as String);
    });
  }

  Future<String> showLoadCertificateDialog() {
    return _channel.invokeMethod('showLoadCertificateDialog').then((value) {
      return Future.value(value as String);
    });
  }
}