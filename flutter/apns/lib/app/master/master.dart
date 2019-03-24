import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Master extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _inputController =InputController();

    return Scaffold(
        appBar: AppBar(title: Text('APNs Provider')),
        body: Container(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            final result = await _inputController.presentInputSheet('请输入 Team ID', '');
            print(result);
          },
        ),
    );
  }
}

class InputController {

  MethodChannel _channel;

  InputController() {
    _channel = MethodChannel('com.Arror.APNs.Input');
  }

  Future<String> presentInputSheet(String title, String initialText) async {
    try {
      final parameters = {
        'title': title,
        'initialText': initialText
      };
      String _value;
      final List<dynamic> result = await _channel.invokeMethod('showInputSheet', [parameters]);
      _value = result.first;
      return Future.value(_value);
    } on PlatformException catch (e) {
      return Future.error(e);
    } 
  }
}
