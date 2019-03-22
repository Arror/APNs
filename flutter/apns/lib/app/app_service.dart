import 'dart:async';
import 'package:apns/bloc.dart';

class AppService implements BLoCBase {

  StreamController<bool> _environmentController = StreamController<bool>();
  Stream<bool> get environmentStream => _environmentController.stream;
  StreamController<bool> _environmentChangeController = StreamController<bool>();
  StreamSink<bool> get environmentChangeSink => _environmentChangeController.sink;

  AppService() {
    _environmentChangeController.stream.listen(_environmentChanged);
  }

  void _environmentChanged(bool newValue) {
    _environmentController.sink.add(newValue);
  }

  @override
  void dispose() {
    _environmentController.close();
    _environmentChangeController.close();
  }
}